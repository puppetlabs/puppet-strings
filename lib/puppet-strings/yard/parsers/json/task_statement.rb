module PuppetStrings::Yard::Parsers::JSON
  # Represents the Puppet Task statement.
  class TaskStatement
    attr_reader :line, :comments, :comments_range

    def initialize(json, file)
      @file = file
      @source = json
      @line = 0
      @comments_range = nil
    end

    def comments_hash_flag
      false
    end

    def show
      ""
    end

    def comments
      ""
    end

    def name
      File.basename(@file).gsub('.json','') || ""
    end

    def description
      @source['description']
    end

    def parameters
      @source['parameters']
    end

  end
end
