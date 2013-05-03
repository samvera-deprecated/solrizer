module Solrizer
  class Suffix

    def initialize(fields)
      @fields = fields
    end

    def multivalued?
      @fields.include? :multivalued
    end

    def stored?
      @fields.include? :stored
    end

    def indexed?
      @fields.include? :indexed
    end

    def data_type
      @fields.first
    end

    def to_s
      stored_suffix = config[:stored_suffix] if stored?
      index_suffix = config[:index_suffix] if indexed?
      multivalued_suffix = config[:multivalued_suffix] if multivalued?
      raise Solrizer::InvalidIndexDescriptor, "Missing datatype for #{@fields}" unless data_type
      type_suffix = config[:type_suffix].call(data_type)
      raise Solrizer::InvalidIndexDescriptor, "Invalid datatype `#{data_type.inspect}'. Must be one of: :date, :time, :text, :text_en, :string, :integer" unless type_suffix

      [config[:suffix_delimiter], type_suffix, stored_suffix, index_suffix, multivalued_suffix].join
    end


    private
    def config
      @config ||= 
      {suffix_delimiter: '_',
      type_suffix: lambda do |type|  
        case type
        when :string, :symbol # TODO `:symbol' usage ought to be deprecated
          's'
        when :text
          't'
        when :text_en
          'te'
        when :date, :time
          'dt'
        when :integer
          'i'
        end
      end,
      stored_suffix: 's', 
      index_suffix: 'i',
      multivalued_suffix: 'm'}
    end
  end
end
