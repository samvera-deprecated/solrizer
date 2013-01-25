require 'active_support'
module Solrizer
  extend ActiveSupport::Autoload

  autoload :Common
  autoload :Extractor
  autoload :Descriptor
  autoload :FieldMapper
  autoload :DefaultDescriptors
  autoload :HTML, 'solrizer/html'
  autoload :VERSION, 'solrizer/version'
  autoload :XML, 'solrizer/xml'

  def self.version
    Solrizer::VERSION
  end

  def self.default_field_mapper
    @@default_field_mapper ||= Solrizer::FieldMapper.new
  end

  def self.default_field_mapper=(field_mapper)
    @@default_field_mapper = field_mapper
  end
end
