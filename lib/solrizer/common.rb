# The goal of this method is to have no dependency on OM, so that NOM or RDF datastreams could use this.

module Solrizer
  # Instructions on how to solrize the field (types and uses)
  class Directive
    attr_accessor :type, :index_as
    def initialize(*args)
      case args
      when Hash
        self.type = args[:type]
        self.index_as = args[:index_as]
      when Array
        self.type = args[0]
        self.index_as = args[1]
      end
    end
  end

  module Common
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      # @param [String] field_name_base the name of the solr field (without the type suffix)
      # @param [Object] value the value to insert into the document
      # @param [Directive] directive instructions on which fields to create
      # @param [Hash] solr_doc the solr_doc to insert into.
      def create_and_insert_terms(field_name_base, value, directive, solr_doc)
        Solrizer.default_field_mapper.solr_names_and_values(field_name_base, value, directive.type, directive.index_as).each do |field_name, field_value|
          unless field_value.join("").strip.empty?
            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, field_name, field_value)
          end
        end
      end
    end
  end
end
