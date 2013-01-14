# The goal of this method is to have no dependency on OM, so that NOM or RDF datastreams could use this.

module Solrizer
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

      def default_field_mapper
        @@default_field_mapper ||= Solrizer::FieldMapper::Default.new
      end

      def default_field_mapper=(obj)
        @@default_field_mapper = obj 
      end
  
      def create_and_insert_terms(field_name_base, value, directive, solr_doc)
        field_mapper ||= default_field_mapper
        field_mapper.solr_names_and_values(field_name_base, value, directive.type, directive.index_as).each do |field_name, field_value|
          unless field_value.join("").strip.empty?
            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, field_name, field_value)
          end
        end
      end
    end
  end
end
