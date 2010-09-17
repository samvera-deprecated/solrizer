require "yaml"

module Solrizer
  module FieldNameMapper
      
    # Module Methods & Attributes
    @@data_types = {}
    @@index_types = {}
    
    # Generates solr field names from settings in solr_mappings
    def self.solr_names(field_name, field_type, index_as = [])
      suffixes = [mapping_lookup(data_types, field_type, field_name, 'data type')]
      suffixes += index_as.map do |ix|
        mapping_lookup(index_types, ix, field_name, 'index type')
      end
      suffixes.delete_if { |s| s.nil? }
      
      convert_method = field_name.kind_of?(Symbol) ? :to_sym : :to_s
      suffixes.map do |suffix|
        (field_name.to_s + suffix.to_s).send(convert_method)
      end
    end
    
    def self.mapping_lookup(mappings, key, field_name, mappings_name)
      return nil unless key
      suffix = mappings[key.to_s]
      unless suffix
        logger.debug "Ignoring #{mappings_name} \"#{key}\" of term #{field_name}, " +
                     "because there is no solr mapping defined for it. Available mappings: #{mappings.keys.inspect}"
      end
      suffix
    end
  
    def self.mappings
      warn 'Warning: Solrizer::FieldNameMapper.mappings is deprecated; use Solrizer::FieldNameMapper.data_types instead'
      self.data_types
    end
  
    def self.data_types
      @@data_types
    end
      
    def self.data_types=(mappings)
      @@data_types = mappings
    end
    
    def self.index_types
      @@index_types
    end
    
    def self.index_types=(mappings)
      @@index_types = mappings
    end

    def self.logger      
      @logger ||= defined?(RAILS_DEFAULT_LOGGER) ? RAILS_DEFAULT_LOGGER : Logger.new(STDOUT)
    end
  
    # Loads solr mappings from yml file.
    # @config_path This is the path to the directory where your mappings file is stored. @default "RAILS_ROOT/config/solr_mappings.yml"
    # @mappings_file This is the filename for your solr mappings YAML file.  @default solr_mappings.yml
    def self.load_mappings( config_path=nil )

      if config_path.nil? 
        if defined?(RAILS_ROOT)
          config_path = File.join(RAILS_ROOT, "config", "solr_mappings.yml")
        end
        # Default to using the config file within the gem 
        if !File.exist?(config_path.to_s)
          config_path = File.join(File.dirname(__FILE__), "..", "..", "config", "solr_mappings.yml")          
        end
      end

      logger.info("SOLRIZER: loading field name mappings from #{File.expand_path(config_path)}")

      config = YAML::load(File.open(config_path))
      self.data_types = config['data_types'] || {}
      self.index_types = config['index_types'] || {}

      self.data_types["id"] ||= "id"
    end
  
    # This ensures that some mappings will always be loaded
    self.load_mappings
    
  end #FieldNameMapper
end #Solrizer
