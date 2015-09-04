module YARD

  class JsonRegistryStore < RegistryStore
    def save(merge=true, file=nil)
      super

      @serializer = Serializers::JsonSerializer.new(@file)

      sdb = Registry.single_object_db
      if sdb == true || sdb == nil
        serialize_output_schema(@store)
      else
        values(false).each do |object|
          serialize_output_schema(object)
        end
      end
      true
    end

    # @param obj [Hash] A hash representing the registry or part of the
    # registry.
    def serialize_output_schema(obj)
        schema = {
          :puppet_functions => [],
          :puppet_providers => [],
          :puppet_classes => [],
          :defined_types => [],
          :puppet_types => [],
        }

        schema[:puppet_functions] += obj.select do |key, val|
          val.type == :method and (val['puppet_4x_function'] or
                                   val['puppet_3x_function'])
        end.values

        schema[:puppet_classes] += obj.select do |key, val|
          val.type == :hostclass
        end.values

        schema[:defined_types] += obj.select do |key, val|
          val.type == :definedtype
        end.values

        schema[:puppet_providers] += obj.select do |key, val|
          val.type == :provider
        end.values

        schema[:puppet_types] += obj.select do |key, val|
          val.type == :type
        end.values

        @serializer.serialize(schema.to_json)
    end
  end

  # Override the serializer because it puts the data at a wacky path and, more
  # importantly, marshals the data with a bunch of non-printable characters.
  module Serializers
    class JsonSerializer < YardocSerializer

      def initialize o
        super
        @options = {
          :basepath => 'doc',
          :extension => 'json',
        }
        @extension = 'json'
        @basepath = 'doc'
      end
      def serialize(data)
        path = File.join(basepath, "registry_dump.#{extension}")
        log.debug "Serializing json to #{path}"
        File.open!(path, "wb") {|f| f.write data }
      end
    end
  end

end
