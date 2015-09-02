# Handles `dispatch` calls within a future parser function declaration. For
# now, it just treats any docstring as an `@overlaod` tag and attaches the
# overload to the parent function.
class PuppetX::PuppetLabs::Strings::YARD::Handlers::PuppetProviderHandler < YARD::Handlers::Ruby::Base
  include PuppetX::PuppetLabs::Strings::YARD::CodeObjects

  handles :command_call, :call

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
    first = statement.children.first.first
    return unless (first.source == 'Puppet::Type') ||
      (first.type == :var_ref &&
      first.source == 'Type') &&
      statement[2].source == 'provide'
    i = statement.index { |s| YARD::Parser::Ruby::AstNode === s && s.type == :ident && s.source == 'provide' }
    provider_name = statement[i+1].jump(:ident).source
    type_name = statement.jump(:symbol).first.source

    obj = ProviderObject.new(:root, provider_name)

    docstring = nil
    features = []
    commands = []
    confines = {}
    defaults = {}
    do_block = statement.jump(:do_block)
    do_block.traverse do |node|
      if is_a_func_call_named?('desc', node)
        content = node.jump(:tstring_content)
        # if we found the string content extract its source
        if content != node
          # The docstring is either the source stripped of heredoc
          # annotations or the raw source.
          if @heredoc_helper.is_heredoc?(content.source)
            docstring = @heredoc_helper.process_heredoc content.source
          else
            docstring = content.source
          end
        end
      elsif is_a_func_call_named?('confine', node)
        node.traverse do |s|
          if s.type == :assoc
            k = s.first.jump(:ident).source
            v = s[1].first.source
            confines[k] = v
          end
        end
      elsif is_a_func_call_named?('has_feature', node)
        list = node.jump :list
        if list != nil && list != node
          features += list.map { |s| s.source if YARD::Parser::Ruby::AstNode === s }.compact
        end
      elsif is_a_func_call_named?('commands', node)
        assoc = node.jump(:assoc)
        if assoc && assoc != node
          ident = assoc.jump(:ident)
          if ident && ident != assoc
            commands << ident.source
          end
        end
      elsif is_a_func_call_named?('defaultfor', node)
        node.traverse do |s|
          if s.type == :assoc
            k = s.first.jump(:ident).source
            v = s[1].first.source
            defaults[k] = v
          end
        end
      end
    end
    obj.features = features
    obj.commands = commands
    obj.confines = confines
    obj.defaults = defaults
    obj.type_name = type_name

    register_docstring(obj, docstring, nil)
    register obj
  end

  def is_a_func_call_named?(name, node)
    (node.type == :fcall || node.type == :command || node.type == :vcall) && node.children.first.source == name
  end
end
