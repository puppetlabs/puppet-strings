module YARD

  class JsonRegistryStore < RegistryStore
    def save(merge=true, file=nil)
      super

      # FIXME: do we need this?
      if file && file != @file
        @file = file
        @serializer = Serializers::JsonSerializer.new(@file)
      end
      @serializer = Serializers::JsonSerializer.new(@file)

      sdb = Registry.single_object_db
      original_extension = @serializer.extension
      @serializer.extension = 'json'
      @serializer.basepath = 'yardoc_json'
      interesting_entries = proc { |key, val|
        [:puppetnamespace, :hostclass,].include? val.type or
        (val.type == :method and (val['puppet_4x_function'] or
        val['puppet_3x_function']))
      }
      rename_methods = proc { |key, value|
        [value.type == :method ? value.name.to_sym : key,
        value]
      }
      if sdb == true || sdb == nil
        @serializer.serialize(Hash[@store.select(&interesting_entries).map(&rename_methods)].to_json)
      else
        values(false).each do |object|
          @serializer.serialize(Hash[object.select(&interesting_entries).map(&rename_methods)].to_json)
        end
      end
      @serializer.extension = original_extension
      true
    end
  end

  # Override the serializer because it puts the data at a whacky path and, more
  # importantly, mashals the data with a bunch of non-printable characters.
  module Serializers
    class JsonSerializer < YardocSerializer
      def serialize(data)
        path = File.join(basepath, "registry_dump.#{extension}")
        require 'pry'; binding.pry
        log.debug "Serializing json to #{path}"
        File.open!(path, "wb") {|f| f.write data }
      end
    end
  end

end
