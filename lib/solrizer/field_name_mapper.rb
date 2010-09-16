require "yaml"

module Solrizer
  module FieldNameMapper
      
  # Module Methods & Attributes
  @@data_types = {}
  @@index_types = {}
  
  # Generates solr field names from settings in solr_mappings
  def self.solr_name(field_name, field_type)
    name = field_name.to_s + self.data_types[field_type.to_s].to_s
    if field_name.kind_of?(Symbol)
      return name.to_sym
    else
      return name.to_s
    end
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

  # def solr_name(field_name, field_type)
  #   FieldNameMapper.solr_name(field_name, field_type)
  # end
  
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
    # self.index_types = config[:index_types] || {}

    self.data_types["id"] ||= "id"
  end
  
  # This ensures that some mappings will always be loaded
  self.load_mappings
  
  end #FieldNameMapper
end #Solrizer
