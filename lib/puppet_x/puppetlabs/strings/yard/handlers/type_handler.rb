# Handles `dispatch` calls within a future parser function declaration. For
# now, it just treats any docstring as an `@overlaod` tag and attaches the
# overload to the parent function.
class PuppetX::PuppetLabs::Strings::YARD::Handlers::PuppetTypeHandler < YARD::Handlers::Ruby::Base
  include PuppetX::PuppetLabs::Strings::YARD::CodeObjects

  handles :call

  process do
    @heredoc_helper = HereDocHelper.new
    # Puppet types always begin with:
    # Puppet::Types.newtype...
    # Therefore, we match the corresponding trees which look like this:
    # s(:call,
    #   s(:const_path_ref,
    #     s(:var_ref, s(:const, "Puppet", ...), ...),
    #   s(:const, "Type", ...),
    # You think this is ugly? It's better than the alternative.
    return unless statement.children.length > 2
    first = statement.children.first
    return unless (first.type == :const_path_ref and
      first.source == 'Puppet::Type') or
      (first.type == :var_ref and
      first.source == 'Type') and
      statement.children[1].source == "newtype"

    # Fetch the docstring for the types. The docstring is the string literal
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

    # The types begin with:
    # Puppet::Types.newtype(:symbol)
    # Jump to the first identifier (':symbol') after the third argument
    # ('(:symbol)') to the current statement
    name = statement.children[2].jump(:ident).source
    parameter_details = []
    property_details = []
    features = []
    obj = TypeObject.new(:root, "#{name}_type") do |o|
      # FIXME: This block gets yielded twice for whatever reason
      parameter_details = []
      property_details = []
      o.parameters = []
      # Find the do block following the Type.
      do_block = statement.jump(:do_block)
      # traverse the do block's children searching for function calls whose
      # identifier is newparam (we're calling the newparam function)
      do_block.traverse do |node|
        if is_param? node
          # The first member of the parameter tuple is the parameter name.
          # Find the second identifier node under the fcall tree. The first one
          # is 'newparam', the second one is the function name.
          # Get its source.
          # The second parameter is nil because we cannot infer types for these
          # functions. In fact, that's a silly thing to ask because ruby
          # types were deprecated with puppet 4 at the same time the type
          # system was created.

          # Because of a ripper bug a symbol identifier is sometimes incorrectly parsed as a keyword.
          # That is, the symbol `:true` will be represented as s(:symbol s(:kw, true...
          param_name = node.children[1].jump(:ident)
          if param_name == node.children[1]
            param_name = node.children[1].jump(:kw)
          end
          param_name = param_name.source
          o.parameters << [param_name, nil]
          parameter_details << {:name => param_name,
            :desc => fetch_description(node), :exists? => true,
            :puppet_type => true,
            :default => fetch_default(node),
            :namevar => is_namevar?(node, param_name, name),
            :parameter => true,
            :allowed_values => get_parameter_allowed_values(node),
          }
        elsif is_prop? node
          # Because of a ripper bug a symbol identifier is sometimes incorrectly parsed as a keyword.
          # That is, the symbol `:true` will be represented as s(:symbol s(:kw, true...
          prop_name = node.children[1].jump(:ident)
          if prop_name == node.children[1]
            prop_name = node.children[1].jump(:kw)
          end
          prop_name = prop_name.source
          property_details << {:name => prop_name,
            :desc => fetch_description(node), :exists? => true,
            :default => fetch_default(node),
            :puppet_type => true,
            :property => true,
            :allowed_values => get_property_allowed_values(node),
            }
        elsif is_feature? node
          features << get_feature(node)
        end
      end
    end
    obj.parameter_details = parameter_details
    obj.property_details = property_details
    obj.features = features
    obj.header_name = name

    register obj
    # Register docstring after the object. If the object already has a
    # docstring, or more likely has parameters documented with the type
    # directive and an empty docstring, we want to override it with the
    # docstring we found, assuming we found one.
    register_docstring(obj, docstring, nil) if docstring
  end


  # See:
  # https://docs.puppetlabs.com/guides/custom_types.html#namevar
  # node should be a parameter
  def is_namevar? node, param_name, type_name
    # Option 1:
    # Puppet::Type.newtype(:name) do
    # ...
    # newparam(:name) do
    #   ...
    # end
    if type_name == param_name
      return true
    end
    # Option 2:
    # newparam(:path, :namevar => true) do
    #   ...
    # end
    if node.children.length >= 2
      node.traverse do |s|
        if s.type == :assoc and s.jump(:ident).source == 'namevar' and s.jump(:kw).source == 'true'
          return true
        end
      end
    end
    # Option 3:
    # newparam(:path) do
    #   isnamevar
    #   ...
    # end
    do_block = node.jump(:do_block).traverse do |s|
      if is_a_func_call_named? 'isnamevar', s
        return true
      end
    end
    # Crazy implementations of types may just call #isnamevar directly on the object.
    # We don't handle this today.
    return false
  end

  def is_param? node
    is_a_func_call_named? 'newparam', node
  end
  def is_prop? node
    is_a_func_call_named? 'newproperty', node
  end

  def is_feature? node
    is_a_func_call_named? 'feature', node
  end

  def is_a_func_call_named? name, node
    (node.type == :fcall or node.type == :command or node.type == :vcall) and node.children.first.source == name
  end

  def get_feature node
    name = node[1].jump(:ident).source
    desc = node[1].jump(:tstring_content).source
    methods = []
    if node[1].length == 4 and node.children[1][2].jump(:ident).source == 'methods'
      arr = node[1][2].jump(:array)
      if arr != node[1][2]
        arr.traverse do |s|
          if s.type == :ident
            methods << s.source
          end
        end
      end
    end
    {
      :name => name,
      :desc => desc,
      :methods => methods != [] ? methods : nil,
    }
  end

  def get_parameter_allowed_values node
    vals = []
    node.traverse do |s|
      if is_a_func_call_named? 'newvalues', s
        list = s.jump(:list)
        if list != s
          vals += list.map { |item| [item.source] if YARD::Parser::Ruby::AstNode === item }
        end
      end
    end
    vals.compact
  end

  # Calls to newvalue only apply to properties, according to Dan & Nan's
  # "Puppet Types and Providers", page 30.
  def get_property_allowed_values node
    vals = get_parameter_allowed_values node
    node.traverse do |s|
      if is_a_func_call_named? 'newvalue', s
        required_features = nil
        s.traverse do |ss|
          if ss.type == :assoc and ss[0].source == ':required_features'
            required_features = ss[1].source
          end
        end
        list = s.jump(:list)
        if list != s
          vals << [list[0].source, required_features].compact
        end
      end
    end
    vals
  end

  def fetch_default node
    do_block = node.jump(:do_block)
    do_block.traverse do |s|
      if is_a_func_call_named? 'defaultto', s
        return s[-1].source
      end
    end
    nil
  end

  def fetch_description(fcall)
    fcall.traverse do |node|
      if is_a_func_call_named? 'desc', node
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
