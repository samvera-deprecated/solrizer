require 'active_support'
require 'active_support/core_ext/module/attribute_accessors'

module Solrizer
  extend ActiveSupport::Autoload

  autoload :Common
  autoload :Extractor
  autoload :Descriptor
  autoload :FieldMapper
  autoload :DefaultDescriptors
  autoload :Suffix
  autoload :HTML, 'solrizer/html'
  autoload :VERSION, 'solrizer/version'
  autoload :XML, 'solrizer/xml'

  mattr_accessor :logger, instance_writer: false

  class << self
    def version
      Solrizer::VERSION
    end

    def default_field_mapper
      @@default_field_mapper ||= Solrizer::FieldMapper.new
    end

    def default_field_mapper=(field_mapper)
      @@default_field_mapper = field_mapper
    end


    def solr_name(*args)
      default_field_mapper.solr_name(*args)
    end

    # @params [Hash] doc the hash to insert the value into
    # @params [String] name the name of the field (without the suffix)
    # @params [String,Date,Array] value the value (or array of values) to be inserted
    # @params [Array,Hash] indexer_args the arguments that find the indexer
    # @returns [Hash] doc the document that was provided with the new field inserted
    def insert_field(doc, name, value, *indexer_args)
      # adding defaults indexer
      indexer_args = [:stored_searchable] if indexer_args.empty?
      default_field_mapper.solr_names_and_values(name, value, indexer_args).each do |k, v|
        doc[k] ||= []
        if v.is_a? Array
          doc[k] += v
        else
          doc[k] = v
        end
      end
      doc
    end

    # @params [Hash] doc the hash to insert the value into
    # @params [String] name the name of the field (without the suffix)
    # @params [String,Date] value the value to be inserted
    # @params [Array,Hash] indexer_args the arguments that find the indexer
    # @returns [Hash] doc the document that was provided with the new field (replacing any field with the same name) 
    def set_field(doc, name, value, *indexer_args)
      # adding defaults indexer
      indexer_args = [:stored_searchable] if indexer_args.empty?
      doc.merge! default_field_mapper.solr_names_and_values(name, value, indexer_args)
      doc
    end
  end
end
