# Re-Introduced for backwards compatibility
module Solrizer::FieldNameMapper
  
  # Module Methods
  
  def self.mappings
    return {"id"=>"id"}
  end
  
  # @deprecated 
  # Previously loaded solr field name mappings from a yaml file.  Doesn't do anything any more.
  def self.load_mappings( arg="arg1")
    puts "Solrizer::FieldNameMapper.load_mappings doesn't do anything any more.  Stop calling it."
  end
  
  def self.default_field_mapper
    @@default_field_mapper ||= Solrizer::FieldMapper::Default.new
  end
  
  def self.default_field_mapper=(field_mapper)
    @@default_field_mapper = field_mapper
  end
  
  def self.solr_name(field_name, field_type, index_type = :searchable)
    self.default_field_mapper.solr_name(field_name, field_type, index_type)
  end
  
  # Class Methods -- These methods will be available on classes that include this Module 
  
  module ClassMethods
    
  end
  
  # Instance Methods -- These methods will be available on instances of classes that include this module
  
  attr_accessor :ox_namespaces
  
  def self.included(klass)
    klass.extend(ClassMethods)
  end
  
  
  def solr_name(field_name, field_type, index_type = :searchable)   
    Solrizer::FieldNameMapper.solr_name(field_name, field_type, index_type)
  end
  
end