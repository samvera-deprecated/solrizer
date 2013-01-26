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

  # @params [Hash] doc the hash to insert the value into
  # @params [String] name the name of the field (without the suffix)
  # @params [String,Date] value the value to be inserted
  # @params [Array,Hash] indexer_args the arguments that find the indexer
  # @returns [Hash] doc the document that was provided with the new field inserted
  def self.insert_field(doc, name, value, *indexer_args)
    # adding defaults indexer 
    indexer_args = [:searchable] if indexer_args.empty?
    default_field_mapper.solr_names_and_values(name, value, indexer_args).each do |k, v|
      doc[k] ||= []
      doc[k] += v
    end
    doc
  end

  # @params [Hash] doc the hash to insert the value into
  # @params [String] name the name of the field (without the suffix)
  # @params [String,Date] value the value to be inserted
  # @params [Array,Hash] indexer_args the arguments that find the indexer
  # @returns [Hash] doc the document that was provided with the new field (replacing any field with the same name) 
  def self.set_field(doc, name, value, *indexer_args)
    # adding defaults indexer 
    indexer_args = [:searchable] if indexer_args.empty?
    doc.merge! default_field_mapper.solr_names_and_values(name, value, indexer_args)
    doc
  end
end
