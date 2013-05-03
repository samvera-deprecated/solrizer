# The goal of this method is to have no dependency on OM, so that NOM or RDF datastreams could use this.

module Solrizer
  module Common
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      # @param [String] field_name_base the name of the solr field (without the type suffix)
      # @param [Object] value the value to insert into the document
      # @param [Array] index_as list of indexers to use (e.g. [:searchable, :facetable])
      # @param [Hash] solr_doc the solr_doc to insert into.
      def create_and_insert_terms(field_name_base, value, index_as, solr_doc)
        index_as.each do |indexer|
          Solrizer.insert_field(solr_doc, field_name_base, value, indexer)
        end
      end
    end
  end
end
