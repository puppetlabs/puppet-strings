# Handles `dispatch` calls within a future parser function declaration. For
# now, it just treats any docstring as an `@overlaod` tag and attaches the
# overload to the parent function.
class PuppetX::PuppetLabs::Strings::YARD::Handlers::PuppetProviderHandler < YARD::Handlers::Ruby::Base
  include PuppetX::PuppetLabs::Strings::YARD::CodeObjects

  handles :call

  process do
    @heredoc_helper = HereDocHelper.new
    # Puppet providers always begin with:
    # Puppet::Types.newtype...
    # Therefore, we match the corresponding trees which look like this:
    # s(:call,
    #   s(:const_path_ref,
    #     s(:var_ref, s(:const, "Puppet", ...), ...),
    #   s(:const, "Type", ...),
    # You think this is ugly? It's better than the alternative.
    return unless statement.children.length > 2
    first = statement.children.first
    return unless first.type == :const_path_ref and
      first.children.length == 2 and
      first.children.map { |o| o.source } == ["Puppet", "Type"] and
      statement.children[1].source == "newtype"

    # Fetch the docstring for the provider. The docstring is the string literal
    # assigned to the @doc parameter or absent, like this:
    # @doc "docstring goes here"
    # We assume that docstrings nodes have the following shape in the source
    # code:
    # ...
    # s(s(:assign,
    #        s(:..., s(:ivar, "@doc", ...), ...),
    #        s(:...,
    #           s(:...,
    #              s(:tstring_content,
    #                 "Manages files, including their content, etc.", ...
    # Initialize the docstring to nil, the default value if we don't find
    # anything
    docstring = nil
    # Walk the tree searching for assignments
    statement.traverse do |node|
      if node.type == :assign
        # Once we have found and assignment, jump to the first ivar
        # (the l-value)
        # If we can't find an ivar return the node.
        ivar = node.jump(:ivar)
        # If we found and  ivar and its source reads '@doc' then...
        if ivar != node and ivar.source == '@doc'
          # find the next string content
          content = node.jump(:tstring_content)
          # if we found the string content extract its source
          if content != node
            # The docstring is either the source stripped of heredoc
            # annotations or the raw source.
            if @heredoc_helper.is_heredoc? content.source
              docstring = @heredoc_helper.process_heredoc content.source
            else
              docstring = content.source
            end
          end
          # Since we found the @doc parameter (regardless of whether we
          # successfully extracted its source), we're done.
          break
        # But if we didn't find the ivar loop around again.
        else
          next
        end
      end
    end

    # The providers begin with:
    # Puppet::Types.newtype(:symbol)
    # Jump to the first identifier (':symbol') after the third argument
    # ('(:symbol)') to the current statement
    name = statement.children[2].jump(:ident).source
    parameter_details = []
    obj = ProviderObject.new(:root, name) do |o|
      # FIXME: This block gets yielded twice for whatever reason
      parameter_details = []
      o.parameters = []
      # Find the de block following the Provider.
      do_block = statement.jump(:do_block)
      # traverse the do block's children searching for function calls whose
      # identifier is newparam (we're calling the newparam function)
      do_block.traverse do |node|
        if node.type == :fcall and node.children.first.source == 'newparam'
          # The first member of the parameter tuple is the parameter name.
          # Find the second identifier node under the fcall tree. The first one
          # is 'newparam', the second one is the function name.
          # Get its source.
          # The second parameter is nil because we cannot infer types for these
          # functions. In fact, that's a silly thing to ask because ruby
          # providers were deprecated with puppet 4 at the same time the type
          # system was created.
          param_name = node.children[1].jump(:ident).source
          o.parameters << [param_name, nil]
          parameter_details << {:name => param_name,
            :desc => fetch_description(node), :exists? => true,
            :provider => true}
        end
      end
    end
    obj.parameter_details = parameter_details

    register_docstring(obj, docstring, nil)

    register obj
  end

  def fetch_description(fcall)
    fcall.traverse do |node|
      if node.type == :command and node.children.first.source == 'desc'
        content = node.jump(:string_content)
        if content != node
          @heredoc_helper = HereDocHelper.new
          if @heredoc_helper.is_heredoc? content.source
            docstring = @heredoc_helper.process_heredoc content.source
          else
            docstring = content.source
          end
          return docstring
        end
      end
    end
    return nil
  end
end
