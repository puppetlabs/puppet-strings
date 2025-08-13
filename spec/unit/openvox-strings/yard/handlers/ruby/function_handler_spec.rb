# frozen_string_literal: true

require 'spec_helper'
require 'openvox-strings/yard'

describe OpenvoxStrings::Yard::Handlers::Ruby::FunctionHandler do
  subject(:spec_subject) do
    YARD::Parser::SourceParser.parse_string(source, :ruby)
    YARD::Registry.all(:puppet_function)
  end

  describe 'parsing source without a function definition' do
    let(:source) { 'puts "hi"' }

    it 'no functions should be in the registry' do
      expect(spec_subject.empty?).to be(true)
    end
  end

  describe 'parsing 3.x API functions' do
    describe 'parsing a function with a missing docstring' do
      let(:source) { <<~SOURCE }
        Puppet::Parser::Functions.newfunction(:foo) do |*args|
        end
      SOURCE

      it 'logs a warning' do
        expect { spec_subject }.to output(/\[warn\]: Missing documentation for Puppet function 'foo' at \(stdin\):1\./).to_stdout_from_any_process
      end
    end

    describe 'parsing a function with a doc parameter' do
      # Bug: Putting `) do |*args|` on the first line rather than right after
      # the end of the heredoc block causes the docstring to be trimmed. This is
      # probably related to https://github.com/lsegal/yard/issues/779. The code
      # in OpenvoxStrings::Yard::Handlers::Ruby::Base has a special work around
      # for this, but it seems to be limited by how much data YARD provides, and
      # it often isn’t enough.
      #
      # Given that this occurs only in old-style functions, it’s probably not
      # worth pursuing.
      let(:source) { <<~SOURCE }
        Puppet::Parser::Functions.newfunction(:foo, doc: <<~'DOC'
            An example 3.x function.
            @param [String] first The first parameter.
            @param second The second parameter.
            @return [Undef] Returns nothing.
          DOC
          ) do |*args|
          # ...
        end
      SOURCE

      it 'registers a function object' do
        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
        expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::RUBY_3X))
        expect(object.name).to eq(:foo)
        expect(object.signature).to eq('foo(String $first, Any $second)')
        expect(object.parameters).to eq([['first', nil], ['second', nil]])
        expect(object.docstring).to eq('An example 3.x function.')
        expect(object.docstring.tags.size).to eq(4)
        tags = object.docstring.tags(:param)
        expect(tags.size).to eq(2)
        expect(tags[0].name).to eq('first')
        expect(tags[0].text).to eq('The first parameter.')
        expect(tags[0].types).to eq(['String'])
        expect(tags[1].name).to eq('second')
        expect(tags[1].text).to eq('The second parameter.')
        expect(tags[1].types).to eq(['Any'])
        tags = object.docstring.tags(:return)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to be_nil
        expect(tags[0].text).to eq('Returns nothing.')
        expect(tags[0].types).to eq(['Undef'])
        tags = object.docstring.tags(:api)
        expect(tags.size).to eq(1)
        expect(tags[0].text).to eq('public')
      end
    end

    describe 'parsing a function with a doc parameter which has a newline between the namespace and the newfunction call' do
      # Bug: Putting `) do |*args|` on the first line rather than right after
      # the end of the heredoc block causes the docstring to be trimmed. This is
      # probably related to https://github.com/lsegal/yard/issues/779. The code
      # in OpenvoxStrings::Yard::Handlers::Ruby::Base has a special work around
      # for this, but it seems to be limited by how much data YARD provides, and
      # it often isn’t enough.
      #
      # Given that this occurs only in old-style functions, it’s probably not
      # worth pursuing.
      let(:source) { <<~SOURCE }
        module Puppet::Parser::Functions
          newfunction(:foo, doc: <<~'DOC'
              An example 3.x function.
              @param [String] first The first parameter.
              @param second The second parameter.
              @return [Undef] Returns nothing.
            DOC
            ) do |*args|
            # ...
          end
        end
      SOURCE

      it 'registers a function object' do
        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
        expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::RUBY_3X))
        expect(object.name).to eq(:foo)
        expect(object.signature).to eq('foo(String $first, Any $second)')
        expect(object.parameters).to eq([['first', nil], ['second', nil]])
        expect(object.docstring).to eq('An example 3.x function.')
        expect(object.docstring.tags.size).to eq(4)
        tags = object.docstring.tags(:param)
        expect(tags.size).to eq(2)
        expect(tags[0].name).to eq('first')
        expect(tags[0].text).to eq('The first parameter.')
        expect(tags[0].types).to eq(['String'])
        expect(tags[1].name).to eq('second')
        expect(tags[1].text).to eq('The second parameter.')
        expect(tags[1].types).to eq(['Any'])
        tags = object.docstring.tags(:return)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to be_nil
        expect(tags[0].text).to eq('Returns nothing.')
        expect(tags[0].types).to eq(['Undef'])
        tags = object.docstring.tags(:api)
        expect(tags.size).to eq(1)
        expect(tags[0].text).to eq('public')
      end
    end

    describe 'parsing a function with a missing @return tag' do
      let(:source) { <<~SOURCE }
        Puppet::Parser::Functions.newfunction(:foo, doc: <<~'DOC') do |*args|
            An example 3.x function.
            @param [String] first The first parameter.
            @param second The second parameter.
          DOC
          # ...
        end
      SOURCE

      it 'logs a warning' do
        expect { spec_subject }.to output(/\[warn\]: Missing @return tag near \(stdin\):1/).to_stdout_from_any_process
      end
    end
  end

  describe 'parsing 4.x API functions' do
    describe 'parsing a function with a missing docstring' do
      let(:source) { <<~SOURCE }
        Puppet::Functions.create_function(:foo) do
        end
      SOURCE

      it 'logs a warning' do
        expect { spec_subject }.to output(/\[warn\]: Missing documentation for Puppet function 'foo' at \(stdin\):1\./).to_stdout_from_any_process
      end
    end

    describe 'parsing a function with a simple docstring' do
      let(:source) { <<~SOURCE }
        # An example 4.x function.
        Puppet::Functions.create_function(:foo) do
        end
      SOURCE

      it 'registers a function object' do
        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
        expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::RUBY_4X))
        expect(object.name).to eq(:foo)
        expect(object.signature).to eq('foo()')
        expect(object.parameters).to eq([])
        expect(object.docstring).to eq('An example 4.x function.')
        expect(object.docstring.tags.size).to eq(1)
        tags = object.docstring.tags(:api)
        expect(tags.size).to eq(1)
        expect(tags[0].text).to eq('public')
      end
    end

    describe 'parsing a function without any dispatches' do
      let(:source) { <<~SOURCE }
        # An example 4.x function.
        Puppet::Functions.create_function(:foo) do
          # @param [Integer] param1 The first parameter.
          # @param param2 The second parameter.
          # @param [String] param3 The third parameter.
          # @return [Undef] Returns nothing.
          def foo(param1, param2, param3 = nil)
          end
        end
      SOURCE

      it 'registers a function object' do
        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
        expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::RUBY_4X))
        expect(object.name).to eq(:foo)
        expect(object.signature).to eq('foo(Integer $param1, Any $param2, Optional[String] $param3 = undef)')
        expect(object.parameters).to eq([['param1', nil], ['param2', nil], %w[param3 undef]])
        expect(object.docstring).to eq('An example 4.x function.')
        expect(object.docstring.tags.size).to eq(5)
        tags = object.docstring.tags(:param)
        expect(tags.size).to eq(3)
        expect(tags[0].name).to eq('param1')
        expect(tags[0].text).to eq('The first parameter.')
        expect(tags[0].types).to eq(['Integer'])
        expect(tags[1].name).to eq('param2')
        expect(tags[1].text).to eq('The second parameter.')
        expect(tags[1].types).to eq(['Any'])
        expect(tags[2].name).to eq('param3')
        expect(tags[2].text).to eq('The third parameter.')
        expect(tags[2].types).to eq(['Optional[String]'])
        tags = object.docstring.tags(:return)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to be_nil
        expect(tags[0].text).to eq('Returns nothing.')
        expect(tags[0].types).to eq(['Undef'])
        tags = object.docstring.tags(:api)
        expect(tags.size).to eq(1)
        expect(tags[0].text).to eq('public')
      end
    end

    describe 'parsing a function with a single dispatch' do
      let(:source) { <<~SOURCE }
        # An example 4.x function.
        Puppet::Functions.create_function(:foo) do
          # @param param1 The first parameter.
          # @param param2 The second parameter.
          # @param param3 The third parameter.
          # @return [Undef] Returns nothing.
          dispatch :foo do
            param          'Integer',       :param1
            param          'Any',           :param2
            optional_param 'Array[String]', :param3
          end

          def foo(param1, param2, param3 = nil)
          end
        end
      SOURCE

      it 'registers a function object without any overload tags' do
        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
        expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::RUBY_4X))
        expect(object.name).to eq(:foo)
        expect(object.signature).to eq('foo(Integer $param1, Any $param2, Optional[Array[String]] $param3)')
        expect(object.parameters).to eq([['param1', nil], ['param2', nil], ['param3', nil]])
        expect(object.docstring).to eq('An example 4.x function.')
        expect(object.docstring.tags(:overload)).to be_empty
        expect(object.docstring.tags.size).to eq(5)
        tags = object.docstring.tags(:param)
        expect(tags.size).to eq(3)
        expect(tags[0].name).to eq('param1')
        expect(tags[0].text).to eq('The first parameter.')
        expect(tags[0].types).to eq(['Integer'])
        expect(tags[1].name).to eq('param2')
        expect(tags[1].text).to eq('The second parameter.')
        expect(tags[1].types).to eq(['Any'])
        expect(tags[2].name).to eq('param3')
        expect(tags[2].text).to eq('The third parameter.')
        expect(tags[2].types).to eq(['Optional[Array[String]]'])
        tags = object.docstring.tags(:return)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to be_nil
        expect(tags[0].text).to eq('Returns nothing.')
        expect(tags[0].types).to eq(['Undef'])
        tags = object.docstring.tags(:api)
        expect(tags.size).to eq(1)
        expect(tags[0].text).to eq('public')
      end
    end

    describe 'parsing a function using only return_type' do
      let(:source) { <<~SOURCE }
        # An example 4.x function.
        Puppet::Functions.create_function(:foo) do
          # @param param1 The first parameter.
          # @param param2 The second parameter.
          # @param param3 The third parameter.
          dispatch :foo do
            param          'Integer',       :param1
            param          'Any',           :param2
            optional_param 'Array[String]', :param3
            return_type 'String'
          end

          def foo(param1, param2, param3 = nil)
            "Bar"
          end
        end
      SOURCE

      it 'does not throw an error with no @return' do
        expect { spec_subject }.not_to raise_error
      end

      it 'contains a return data type' do
        tags = spec_subject.first.docstring.tags(:return)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to be_nil
        expect(tags[0].types).to eq(['String'])
      end
    end

    describe 'parsing a function with various dispatch parameters.' do
      let(:source) { <<~SOURCE }
        # An example 4.x function.
        Puppet::Functions.create_function(:foo) do
          # @param param1 The first parameter.
          # @param param2 The second parameter.
          # @param param3 The third parameter.
          # @param param4 The fourth parameter.
          # @return [Undef] Returns nothing.
          dispatch :foo do
            param          'String',  :param1
            required_param 'Integer', :param2
            optional_param 'Array',   :param3
            repeated_param 'String',  :param4
          end
        end
      SOURCE

      it 'registers a function object with the expected parameters' do
        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
        expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::RUBY_4X))
        expect(object.name).to eq(:foo)
        expect(object.signature).to eq('foo(String $param1, Integer $param2, Optional[Array] $param3, String *$param4)')
        expect(object.parameters).to eq([['param1', nil], ['param2', nil], ['param3', nil], ['*param4', nil]])
        expect(object.docstring).to eq('An example 4.x function.')
        expect(object.docstring.tags(:overload)).to be_empty
        expect(object.docstring.tags.size).to eq(6)
        tags = object.docstring.tags(:param)
        expect(tags.size).to eq(4)
        expect(tags[0].name).to eq('param1')
        expect(tags[0].text).to eq('The first parameter.')
        expect(tags[0].types).to eq(['String'])
        expect(tags[1].name).to eq('param2')
        expect(tags[1].text).to eq('The second parameter.')
        expect(tags[1].types).to eq(['Integer'])
        expect(tags[2].name).to eq('param3')
        expect(tags[2].text).to eq('The third parameter.')
        expect(tags[2].types).to eq(['Optional[Array]'])
        expect(tags[3].name).to eq('*param4')
        expect(tags[3].text).to eq('The fourth parameter.')
        expect(tags[3].types).to eq(['String'])
        tags = object.docstring.tags(:return)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to be_nil
        expect(tags[0].text).to eq('Returns nothing.')
        expect(tags[0].types).to eq(['Undef'])
        tags = object.docstring.tags(:api)
        expect(tags.size).to eq(1)
        expect(tags[0].text).to eq('public')
      end
    end

    describe 'parsing a function with an optional repeated param.' do
      let(:source) { <<~SOURCE }
        # An example 4.x function.
        Puppet::Functions.create_function(:foo) do
          # @param param The first parameter.
          # @return [Undef] Returns nothing.
          dispatch :foo do
            optional_repeated_param 'String',  :param
          end
        end
      SOURCE

      it 'registers a function object with the expected parameters' do
        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
        expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::RUBY_4X))
        expect(object.name).to eq(:foo)
        expect(object.signature).to eq('foo(Optional[String] *$param)')
        expect(object.parameters).to eq([['*param', nil]])
        expect(object.docstring).to eq('An example 4.x function.')
        expect(object.docstring.tags(:overload)).to be_empty
        expect(object.docstring.tags.size).to eq(3)
        tags = object.docstring.tags(:param)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to eq('*param')
        expect(tags[0].text).to eq('The first parameter.')
        expect(tags[0].types).to eq(['Optional[String]'])
        tags = object.docstring.tags(:return)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to be_nil
        expect(tags[0].text).to eq('Returns nothing.')
        expect(tags[0].types).to eq(['Undef'])
        tags = object.docstring.tags(:api)
        expect(tags.size).to eq(1)
        expect(tags[0].text).to eq('public')
      end
    end

    describe 'parsing a function with a block param with one parameter' do
      let(:source) { <<~SOURCE }
        # An example 4.x function.
        Puppet::Functions.create_function(:foo) do
          # @param a_block The block parameter.
          # @return [Undef] Returns nothing.
          dispatch :foo do
            block_param :a_block
          end
        end
      SOURCE

      it 'registers a function object with the expected parameters' do
        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
        expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::RUBY_4X))
        expect(object.name).to eq(:foo)
        expect(object.signature).to eq('foo(Callable &$a_block)')
        expect(object.parameters).to eq([['&a_block', nil]])
        expect(object.docstring).to eq('An example 4.x function.')
        expect(object.docstring.tags(:overload)).to be_empty
        expect(object.docstring.tags.size).to eq(3)
        tags = object.docstring.tags(:param)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to eq('&a_block')
        expect(tags[0].text).to eq('The block parameter.')
        expect(tags[0].types).to eq(['Callable'])
        tags = object.docstring.tags(:return)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to be_nil
        expect(tags[0].text).to eq('Returns nothing.')
        expect(tags[0].types).to eq(['Undef'])
        tags = object.docstring.tags(:api)
        expect(tags.size).to eq(1)
        expect(tags[0].text).to eq('public')
      end
    end

    describe 'parsing a function with a block param with two parameter' do
      let(:source) { <<~SOURCE }
        # An example 4.x function.
        Puppet::Functions.create_function(:foo) do
          # @param a_block The block parameter.
          # @return [Undef] Returns nothing.
          dispatch :foo do
            optional_block_param 'Callable[String]', :a_block
          end
        end
      SOURCE

      it 'registers a function object with the expected parameters' do
        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
        expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::RUBY_4X))
        expect(object.name).to eq(:foo)
        expect(object.signature).to eq('foo(Optional[Callable[String]] &$a_block)')
        expect(object.parameters).to eq([['&a_block', nil]])
        expect(object.docstring).to eq('An example 4.x function.')
        expect(object.docstring.tags(:overload)).to be_empty
        expect(object.docstring.tags.size).to eq(3)
        tags = object.docstring.tags(:param)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to eq('&a_block')
        expect(tags[0].text).to eq('The block parameter.')
        expect(tags[0].types).to eq(['Optional[Callable[String]]'])
        tags = object.docstring.tags(:return)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to be_nil
        expect(tags[0].text).to eq('Returns nothing.')
        expect(tags[0].types).to eq(['Undef'])
        tags = object.docstring.tags(:api)
        expect(tags.size).to eq(1)
        expect(tags[0].text).to eq('public')
      end
    end
  end

  describe 'parsing a function with a multiple dispatches' do
    let(:source) { <<~SOURCE }
      # An example 4.x function.
      Puppet::Functions.create_function(:foo) do
        # The first overload.
        # @param param1 The first parameter.
        # @param param2 The second parameter.
        # @param param3 The third parameter.
        # @return [Undef] Returns nothing.
        dispatch :foo do
          param          'Integer',       :param1
          param          'Any',           :param2
          optional_param 'Array[String]', :param3
        end

        # The second overload.
        # @param param The first parameter.
        # @param block The block parameter.
        # @return [String] Returns a string.
        dispatch :other do
          param 'Boolean', :param
          block_param
        end

        def foo(param1, param2, param3 = nil)
        end

        def other(b)
          'lol'
        end
      end
    SOURCE

    it 'registers a function object with overload tags' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
      expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::RUBY_4X))
      expect(object.name).to eq(:foo)
      expect(object.signature).to eq('')
      expect(object.parameters).to eq([])
      expect(object.docstring).to eq('An example 4.x function.')
      expect(object.docstring.tags(:param)).to be_empty
      expect(object.docstring.tags(:return)).to be_empty
      expect(object.docstring.tags.size).to eq(3)
      overloads = object.docstring.tags(:overload)
      expect(overloads.size).to eq(2)
      expect(overloads[0]).to be_a(OpenvoxStrings::Yard::Tags::OverloadTag)
      expect(overloads[0].docstring).to eq('The first overload.')
      expect(overloads[0].signature).to eq('foo(Integer $param1, Any $param2, Optional[Array[String]] $param3)')
      expect(overloads[0].tags.size).to eq(4)
      tags = overloads[0].tags(:param)
      expect(tags.size).to eq(3)
      expect(tags[0].name).to eq('param1')
      expect(tags[0].text).to eq('The first parameter.')
      expect(tags[0].types).to eq(['Integer'])
      expect(tags[1].name).to eq('param2')
      expect(tags[1].text).to eq('The second parameter.')
      expect(tags[1].types).to eq(['Any'])
      expect(tags[2].name).to eq('param3')
      expect(tags[2].text).to eq('The third parameter.')
      expect(tags[2].types).to eq(['Optional[Array[String]]'])
      tags = overloads[0].tags(:return)
      expect(tags.size).to eq(1)
      expect(tags[0].name).to be_nil
      expect(tags[0].text).to eq('Returns nothing.')
      expect(tags[0].types).to eq(['Undef'])
      expect(overloads[1]).to be_a(OpenvoxStrings::Yard::Tags::OverloadTag)
      expect(overloads[1].docstring).to eq('The second overload.')
      expect(overloads[1].signature).to eq('foo(Boolean $param, Callable &$block)')
      expect(overloads[1].tags.size).to eq(3)
      tags = overloads[1].tags(:param)
      expect(tags.size).to eq(2)
      expect(tags[0].name).to eq('param')
      expect(tags[0].text).to eq('The first parameter.')
      expect(tags[0].types).to eq(['Boolean'])
      expect(tags[1].name).to eq('&block')
      expect(tags[1].text).to eq('The block parameter.')
      expect(tags[1].types).to eq(['Callable'])
      tags = overloads[1].tags(:return)
      expect(tags.size).to eq(1)
      expect(tags[0].name).to be_nil
      expect(tags[0].text).to eq('Returns a string.')
      expect(tags[0].types).to eq(['String'])
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')
    end
  end

  describe 'parsing a function with a namespaced name' do
    let(:source) { <<~SOURCE }
      # An example 4.x function.
      Puppet::Functions.create_function(:'foo::bar::baz') do
        # @return [Undef]
        dispatch :foo do
        end
      end
    SOURCE

    it 'outputs the name correctly as a symbol' do
      expect(spec_subject.size).to eq(1)
      expect(spec_subject.first.name).to eq(:'foo::bar::baz')
    end
  end

  describe 'parsing a function with a missing parameter' do
    let(:source) { <<~SOURCE }
      # An example 4.x function.
      Puppet::Functions.create_function(:foo) do
        # @param missing A missing parameter.
        # @return [Undef] Returns nothing.
        dispatch :foo do
        end
      end
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }.to output(/\[warn\]: The @param tag for parameter 'missing' has no matching parameter at \(stdin\):5/).to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a missing @param tag' do
    let(:source) { <<~SOURCE }
      # An example 4.x function.
      Puppet::Functions.create_function(:foo) do
        # @return [Undef] Returns nothing.
        dispatch :foo do
          param 'String', :param1
        end
      end
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }.to output(/\[warn\]: Missing @param tag for parameter 'param1' near \(stdin\):5/).to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a typed @param tag' do
    let(:source) { <<~SOURCE }
      # An example 4.x function.
      Puppet::Functions.create_function(:foo) do
        # @param [Integer] param1 The first parameter.
        # @return [Undef] Returns nothing.
        dispatch :foo do
          param 'String', :param1
        end
      end
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }
        .to output(
          /\[warn\]: The @param tag for parameter 'param1' should not contain a type specification near \(stdin\):6: ignoring in favor of dispatch type information\./,
        )
        .to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a typed @param tag' do
    let(:source) { <<~SOURCE }
      # An example 4.x function.
      Puppet::Functions.create_function(:foo) do
        # @param param1 The first parameter.
        dispatch :foo do
          param 'String', :param1
        end
      end
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }.to output(/\[warn\]: Missing @return tag near \(stdin\):4/).to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a root @param tag' do
    let(:source) { <<~SOURCE }
      # An example 4.x function.
      # @param param Nope.
      Puppet::Functions.create_function(:foo) do
        # @return [Undef]
        dispatch :foo do
        end
      end
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }
        .to output(
          /\[warn\]: The docstring for Puppet 4.x function 'foo' contains @param tags near \(stdin\):3: parameter documentation should be made on the dispatch call\./,
        )
        .to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a root @overload tag' do
    let(:source) { <<~SOURCE }
      # An example 4.x function.
      # @overload foo
      Puppet::Functions.create_function(:foo) do
        # @return [Undef]
        dispatch :foo do
        end
      end
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }
        .to output(
          /\[warn\]: The docstring for Puppet 4.x function 'foo' contains @overload tags near \(stdin\):3: overload tags are automatically generated from the dispatch calls\./,
        )
        .to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a root @return tag' do
    let(:source) { <<~SOURCE }
      # An example 4.x function.
      # @return [Undef] foo
      Puppet::Functions.create_function(:foo) do
        # @return [Undef]
        dispatch :foo do
        end
      end
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }
        .to output(
          /\[warn\]: The docstring for Puppet 4.x function 'foo' contains @return tags near \(stdin\):3: return value documentation should be made on the dispatch call\./,
        )
        .to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a summary' do
    context 'when the summary has fewer than 140 characters' do
      let(:source) { <<~SOURCE }
        # An example 4.x function.
        # @summary A short summary.
        Puppet::Functions.create_function(:foo) do
          # @return [Undef]
          dispatch :foo do
          end
        end
      SOURCE

      it 'parses the summary' do
        expect { spec_subject }.not_to output.to_stdout_from_any_process
        expect(spec_subject.size).to eq(1)
        summary = spec_subject.first.tags(:summary)
        expect(summary.first.text).to eq('A short summary.')
      end
    end

    context 'when the summary has more than 140 characters' do
      let(:source) { <<~SOURCE }
        # An example 4.x function.
        # @summary A short summary that is WAY TOO LONG. AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH this is not what a summary is for! It should be fewer than 140 characters!!
        Puppet::Functions.create_function(:foo) do
          # @return [Undef]
          dispatch :foo do
          end
        end
      SOURCE

      it 'logs a warning' do
        expect { spec_subject }.to output(/\[warn\]: The length of the summary for puppet_function 'foo' exceeds the recommended limit of 140 characters./).to_stdout_from_any_process
      end
    end
  end
end
