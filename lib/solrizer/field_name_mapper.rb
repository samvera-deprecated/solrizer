# Re-Introduced for backwards compatibility
module Solrizer::FieldNameMapper
    
  # Class Methods -- These methods will be available on classes that include this Module 
  
  module ClassMethods
    def mappings
      return self.default_field_mapper.mappings
    end

    def id_field
      return self.default_field_mapper.id_field
    end

    # Re-loads solr mappings for the default field mapper's class 
    # and re-sets the default field mapper to an FieldMapper instance with those mappings.
    def load_mappings( config_path=nil)
      self.default_field_mapper.class.load_mappings(config_path)
      self.default_field_mapper = self.default_field_mapper.class.new
    end
    
    def solr_name(field_name, field_type, index_type = :searchable)
      self.default_field_mapper.solr_name(field_name, field_type, index_type)
    end
    
    def default_field_mapper
      @@default_field_mapper ||= Solrizer::FieldMapper::Default.new
    end

    def default_field_mapper=(field_mapper)
      @@default_field_mapper = field_mapper
    end
  end
  
  # Instance Methods -- These methods will be available on instances of classes that include this module
  
  attr_accessor :ox_namespaces
  
  def self.included(klass)
    klass.extend(ClassMethods)
  end
  
  
  def solr_name(field_name, field_type, index_type = :searchable)   
    self.class.solr_name(field_name, field_type, index_type)
  end
  
end