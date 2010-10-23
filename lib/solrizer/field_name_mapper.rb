module Solrizer::FieldNameMapper
  
  # Module Methods
  
  def self.mappings
    return {:id=>"id"}
  end
  
  # Class Methods -- These methods will be available on classes that include this Module 
  
  module ClassMethods
    
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
    self.class.default_field_mapper.solr_name(field_name, field_type, index_type)
  end
  
end