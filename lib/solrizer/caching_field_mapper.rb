module Solrizer
  class CachingFieldMapper
    # @param [FieldMapper] the object that changes arguments into a name.
    def initialize(field_mapper)
      @field_mapper = field_mapper
    end

    # Given a field name, index_type, etc., returns the corresponding Solr name.
    # @param [String] field_name the ruby (term) name which will get a suffix appended to become a Solr field name
    # @param opts - index_type is only needed if the FieldDescriptor requires it (e.g. :searcahble)
    # @return [String] name of the solr field, based on the params
    def solr_name(*args)
      cache(args) do
        @field_mapper.solr_name(*args)
      end
    end

    private

      def cache(*args)
        @cache ||= {}
        @cache[args] ||= yield(*args)
      end
  end
end

