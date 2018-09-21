require 'active_support'
require 'active_support/core_ext/module/attribute_accessors'
require 'deprecation'

module Solrizer
  Deprecation.warn(self, "Solrizer has been merged into ActiveFedora please see (https://github.com/samvera/active_fedora/pull/1223)." \
                         "  This means that this Gem is no longer actively maintained, and that there are plans for it to be deprecated." \
                         "  Please see the ActiveFedora documentation for further reference: https://github.com/samvera/active_fedora/wiki.")
  extend ActiveSupport::Autoload

  autoload :CachingFieldMapper
  autoload :Common
  autoload :Descriptor
  autoload :FieldMapper
  autoload :DefaultDescriptors
  autoload :Suffix
  autoload :VERSION, 'solrizer/version'

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

    def caching_field_mapper
      @caching_field_mapper ||= Solrizer::CachingFieldMapper.new(default_field_mapper)
    end

    def solr_name(*args)
      caching_field_mapper.solr_name(*args)
    end
    deprecation_deprecate solr_name: 'use ActiveFedora.index_field_mapper.solr_name instead'

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
