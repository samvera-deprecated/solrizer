require "loggable"
require 'active_support/core_ext/class/attribute'
module Solrizer

  class SolrizerError < RuntimeError; end #nodoc#
  class InvalidIndexDescriptor < SolrizerError; end #nodoc# 
  class UnknownIndexMacro < SolrizerError; end #nodoc# 
  # Maps Term names and values to Solr fields, based on the Term's data type and any index_as options.
  #
  # The basic structure of a mapper is:
  #
  # == Mapping on Index Type
  #
  # To add a custom mapper to the default mapper
  # 
  #   module Solrizer::DefaultDescriptors
  #     def self.some_field_type
  #       @some_field_type ||= Descriptor.new(:string, :stored, :indexed, :multivalued)
  #     end
  #
  #     # Or some totally different field:
  #     def self.edible
  #       @some_field_type ||= EdibleDescriptor.new()
  #     end
  #
  #     class EdibleDescriptor < Solrizer::Descriptor
  #       def name_and_converter(field_name, field_type)
  #         [field_name + '_food']
  #       end
  #     end
  #   end
  #
  #   #   t.dish_name   :index_as => [:some_field_type]           -maps to->   dish_name_ssim
  #   #   t.ingredients :index_as => [:some_field_type, :edible]  -maps to->   ingredients_ssim, ingredients_food
  #
  # (See Solrizer::XML::TerminologyBasedSolrizer for instructions on applying a custom mapping once you have defined it.)
  #
  #
  # == Custom Value Converters
  #
  # All of the above applies to the generation of Solr names. Mappers can also provide custom conversion logic for the 
  # generation of Solr values by attaching a custom value converter block to a data type:
  #
  #   require 'time'
  #   module Solrizer::DefaultDescriptors
  #     def self.searchable
  #       @searchable ||= SearchableDescriptor.new(:string, :stored, :indexed, :multivalued, converter: my_converter)
  #     end
  #
  #     def self.my_converter
  #       lambda do |type|
  #         case type
  #         when :date
  #           lambda { |value| Time.parse(value).utc.to_i }
  #         else
  #           lambda { |value| value.to_s.strip }
  #         end
  #       end
  #     end
  #   end
  #
  # This example converts searchable dates to milliseconds, and strips extra whitespace from all other searchable data types.
  #
  #
  # == ID Field
  #
  # In addition to the normal field mappings, Solrizer gives special treatment to an ID field. If you want that
  # logic (and you probably do), specify a name for this field:
  #
  #   Solrizer::FieldMapper.id_field  = 'id' 
  #
  #
  # == Extending the Default
  #
  # The default mapper is Solrizer::FieldMapper. You can customize the default mapping by subclassing it.
  # For example, to override the ID field name and the default suffix for sortable, and inherit everything else:
  #
  #   class CustomMapperBasedOnDefault < Solrizer::FieldMapper
  #     self.id_field = 'guid'
  #
  #     module MyCustomIndexDescriptors
  #       def self.my_converter
  #         @my_converter ||= Descriptor.new(:string, :stored, :indexed, :multivalued)
  #       end
  #     end
  #
  #     self.descriptors = [MyCustomIndexDescriptors, DefaultDescriptors]
  #   end
  
  class FieldMapper
    
    include Loggable
    
    # ------ Instance methods ------
    
    attr_reader :id_field, :default_index_types, :mappings
    class_attribute :id_field
    class_attribute :descriptors
    # set defaults
    self.descriptors = [DefaultDescriptors]
    self.id_field = 'id'

    
    def initialize
      @mappings = {}
      self.id_field = self.class.id_field
    end

    # Given a specific field name, data type, and index type, returns the corresponding solr name.
    
    # TODO field type is the input format, maybe we could just detect that?
    # @param index_type is a FieldDescriptor
    def solr_name(field_name, field_type, index_type = nil)
      # if they don't provide an index type, give them a basic indexed field for that type.
      # This is primarily to provide backward compatibility.  TODO deprecate this behavior
      index_type = index_type_macro(:simple) if index_type.nil?
      solr_name_and_converter(field_name, field_type, index_type).first
    end

    # @param index_type [Symbol]
    # search through the descriptors (class attribute) until a module is found that responds to index_type, then call it.
    def index_type_macro(index_type)
      klass = self.class.descriptors.find { |klass| klass.respond_to? index_type}
      if klass
        klass.send(index_type)
      else
        raise UnknownIndexMacro, "Unable to find `#{index_type}' in #{self.class.descriptors}"
      end
    end

    # @param index_type is a FieldDescriptor or a symbol that points to a method that returns a field descriptor
    def solr_name_and_converter(field_name, field_type, index_type)
      index_type = case index_type
      when Symbol
        index_type_macro(index_type)
      when Array
        raise "It's not yet supposed to be an array"
        #IndexDescriptors::Descriptor.new(*index_type)
      else
        index_type
      end


      raise InvalidIndexDescriptor, "index type should be an IndexDescriptor, you passed: #{index_type}" unless index_type.kind_of? Descriptor
      index_type.name_and_converter(field_name, field_type)
    end

    # Given a field name-value pair, a data type, and an array of index types, returns a hash of
    # mapped names and values. The values in the hash are _arrays_, and may contain multiple values.
    
    def solr_names_and_values(field_name, field_value, field_type, index_types)
      # Determine the set of index types, adding defaults and removing not_xyz
      
      index_types ||= []
      index_types.uniq!
      index_types.dup.each do |index_type|
        if index_type.to_s =~ /^not_(.*)/
          index_types.delete index_type # not_foo
          index_types.delete $1.to_sym  # foo
        end
      end
      
      # Map names and values
      
      results = {}
      
      index_types.each do |index_type|
        # Get mapping for field
        name, converter = solr_name_and_converter(field_name, field_type, index_type)
        next unless name
        
        # Is there a custom converter?
        # TODO instead of a custom converter, look for input data type and output data type. Create a few methods that can do that cast.

        value = if converter
          if converter.arity == 1
            converter.call(field_value)
          else
            converter.call(field_value, field_name)
          end
        else
          field_value.to_s
        end
        
        # Add mapped name & value, unless it's a duplicate
        values = (results[name] ||= [])
        values << value unless value.nil? || values.include?(value)
      end
      
      results
    end
    
  public

    protected

    def self.iso8601_date(value)
      begin 
        if value.is_a?(Date) 
          DateTime.parse(value.to_s).to_time.utc.iso8601 
        elsif !value.empty?
          DateTime.parse(value).to_time.utc.iso8601
        end
      rescue ArgumentError => e
        raise ArgumentError, "Unable to parse `#{value}' as a date-time object"
      end
    end
    
  end
    
end
