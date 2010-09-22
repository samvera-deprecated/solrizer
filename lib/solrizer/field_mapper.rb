module Solrizer
  class FieldMapper
    
    # ------ Class methods ------
    
    @@instance_init_actions = Hash.new { |h,k| h[k] = [] }
    
    def self.id_field(field_name)
      add_instance_init_action do
        @id_field = field_name
      end
    end
    
    def self.index_as(index_type, opts = {}, &block)
      add_instance_init_action do
        mapping = (@mappings[index_type] ||= IndexTypeMapping.new)
        mapping.opts.merge! opts
        yield DataTypeMappingBuilder.new(mapping) if block_given?
      end
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
  
  public
    
    # ------ Instance methods ------
    
    attr_reader :id_field, :default_index_types
    
    def initialize
      @mappings = {}
      self.class.apply_instance_init_actions(self)
      @default_index_types = @mappings.select { |ix_type, mapping| mapping.opts[:default] }.map(&:first)
    end

    def solr_name(field_name, field_type, index_type = :searchable)
      name, mapping, data_type_mapping = solr_name_and_mappings(field_name, field_type, index_type)
      name
    end

    def solr_names_and_values(field_name, field_value, field_type, index_types)
      # Determine the set of index types, adding defaults and removing not_xyz
      
      index_types += default_index_types
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
        name, mapping, data_type_mapping = solr_name_and_mappings(field_name, field_type, index_type)
        next unless name
        
        value = if data_type_mapping && data_type_mapping.converter
          converter = data_type_mapping.converter
          if converter.arity == 1
            converter.call(field_value)
          else
            converter.call(field_value, field_name)
          end
        else
          field_value
        end
        
        values = (results[name] ||= [])
        values << value unless values.contains?(value)
      end
      
      results
    end
  
    def logger
      @logger ||= defined?(RAILS_DEFAULT_LOGGER) ? RAILS_DEFAULT_LOGGER : Logger.new(STDOUT)
    end
    
  private
  
    def solr_name_and_mappings(field_name, field_type, index_type)
      mapping = @mappings[index_type]
      unless mapping
        logger.debug "Unknown index type '#{index_type}' for field #{field_name}"
        return nil
      end
      
      data_type_mapping = mapping.data_types[field_type] || mapping.data_types[:default]
      
      suffix = data_type_mapping.opts[:suffix] if data_type_mapping
      suffix ||= mapping.opts[:suffix]
      name = field_name + suffix
      
      [name, mapping, data_type_mapping]
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
    
    # ------ Default mapper ------
  
  public

    class Default < FieldMapper
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
    
  end

  # class CustomFieldMapper < DefaultFieldMapper
  #   index_as :mungeable, :suffix => '_munge'
  #   index_as :edible, :suffix => '_tasty' do |t|
  #     t.integer :suffix => '_tastyint'
  #     t.default do |value|
  #       'food' + value
  #     end
  #   end
  #   index_as :sortable do |t|
  #     t.date do |value|
  #       # Sort by converting time to seconds since 1970 UTC
  #       Time.parse(value).utc.to_f
  #     end
  #   end
  # end
    
end
