module Solrizer
  class FieldMapper
    
    # Class methods
    
    @@instance_init_actions = Hash.new { |h,k| h[k] = [] }
    
    def self.id_field(field_name)
    end
    
    def self.index_as(index_type, opts = {}, &block)
      add_instance_init_action do
        mapping = (@mappings[index_type] ||= IndexTypeMapping.new)
        mapping.opts.merge! opts
        yield DataTypeMappingBuilder.new(mapping) if block_given?
      end
    end
  
    # Instance methods
    
    def initialize
      @mappings = {}
      self.class.apply_instance_init_actions(self)
    end

    def solr_name(field_name, field_type, index_type = :searchable)
      mapping = @mappings[index_type]
      return nil unless mapping
      
      data_type_mapping = mapping.data_types[field_type] || mapping.data_types[:default]
      suffix = data_type_mapping.opts[:suffix] if data_type_mapping
      suffix ||= mapping.opts[:suffix]
      
      return field_name + suffix
    end

    def solr_names_and_values(field_name, field_value, field_type, index_types)
    end
  
  private
  
    def self.add_instance_init_action(&block)
      @@instance_init_actions[self] << lambda do |mapper|
        mapper.instance_eval &block
      end
    end
  
    def self.apply_instance_init_actions(instance)
      if self.superclass.respond_to? :apply_instance_init_actions
        self.superclass.apply_instance_init_actions(instance)
      end
      @@instance_init_actions[self].each do |action|
        action.call(instance)
      end
    end

    class IndexTypeMapping
      attr_accessor :opts, :data_types
      
      def initialize
        @opts = {}
        @data_types = {}
      end
    end
    
    class DataTypeMapping
      attr_accessor :opts, :converter
      
      def initialize
        @opts = {}
      end
    end
    
    class DataTypeMappingBuilder
      def initialize(index_type_mapping)
        @index_type_mapping = index_type_mapping
      end
      
      def method_missing(method, *args, &block)
        data_type_mapping = (@index_type_mapping.data_types[method] ||= DataTypeMapping.new)
        data_type_mapping.opts.merge! args[0] if args.length > 0
        data_type_mapping.converter = block if block_given?
      end
    end
    
  end

  class DefaultFieldMapper < FieldMapper
    id_field 'id'
    index_as :searchable, :default => true do |t|
      t.date    :suffix => '_date'
      t.string  :suffix => '_t'
      t.text    :suffix => '_t'
      t.symbol  :suffix => '_s'
      t.integer :suffix => '_i'
      t.long    :suffix => '_l'
      t.boolean :suffix => '_b'
      t.float   :suffix => '_f'
      t.double  :suffix => '_d'
    end
    index_as :displayable,          :suffix => '_display'
    index_as :facetable,            :suffix => '_facet'
    index_as :sortable,             :suffix => '_sort'
    index_as :unstemmed_searchable, :suffix => '_unstem_search'
  end

  # class CustomFieldMapper < DefaultFieldMapper
  #   index_as :mungeable, :suffix => '_munge'
  #   index_as :edible, :suffix => '_tasty' do |t|
  #     t.string, :suffix => '_tasty_string'
  #     t.symbol, :suffix => '_tasty_string'
  #     t.integer do |value|
  #       'food' + value
  #     end
  #   end
  # end
  # 
  # class CustomFieldMapper < DefaultFieldMapper
  #   index_as :sortable do |t|
  #     t.default do |value|
  #       # Sort by converting time to seconds since 1970 UTC
  #       Time.parse(value).utc.to_f
  #     end
  #   end
  # end


  # class CustomFieldMapper < DefaultFieldMapper
  #   index_as :edible, :suffix => '_x' do |t|
  #     t.default do |value|
  #       'food' + value
  #     end
  #   end
  #   index_as :flammable, :suffix => '_x' do |t|
  #     t.default do |value|
  #       'flame' + value
  #     end
  #   end
  # end
    
end
