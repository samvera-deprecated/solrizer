module Solrizer
  class Descriptor
    attr_reader :index_type
    def initialize(*args)
      if args.last.kind_of? Hash
        opts = args.pop
        @converter = opts[:converter] 
      end
      @index_type = args
      raise Solrizer::InvalidIndexDescriptor, "Invalid index type passed to Sorizer.solr_name.  It should be an array like [:string, :indexed, :stored, :multivalued]. You provided: `#{@index_type}'" unless index_type.kind_of? Array
    end

    def name_and_converter(field_name, field_type)
      [field_name.to_s + suffix(field_type), converter(field_type)]
    end

    protected
    def suffix(field_type)
      evaluated_type = index_type.first.kind_of?(Proc) ? index_type.first.call(field_type) : index_type.dup
      stored_suffix = config[:stored_suffix] if evaluated_type.delete(:stored)
      index_suffix = config[:index_suffix] if evaluated_type.delete(:indexed)
      multivalued_suffix = config[:multivalued_suffix] if evaluated_type.delete(:multivalued)
      index_datatype = evaluated_type.first
      raise Solrizer::InvalidIndexDescriptor, "Missing datatype for #{evaluated_type}" unless index_datatype
      type_suffix = config[:type_suffix].call(index_datatype)
      raise Solrizer::InvalidIndexDescriptor, "Invalid datatype `#{index_datatype.inspect}'. Must be one of: :date, :text, :text_en, :string, :integer" unless type_suffix

      suffix = [config[:suffix_delimiter], type_suffix, stored_suffix, index_suffix, multivalued_suffix].join
    end

    def converter(field_type)
      @converter.call(field_type) if @converter
    end

    private
    def config
      @config ||= 
      {suffix_delimiter: '_',
      type_suffix: lambda do |type|  
        case type
        when :string, :symbol # TODO `:symbol' useage ought to be deprecated
          's'
        when :text
          't'
        when :text_en
          'te'
        when :date
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
