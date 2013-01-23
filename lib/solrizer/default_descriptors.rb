module Solrizer
  module DefaultDescriptors

    # Produces a _sim suffix
    def self.facetable
      @facetable ||= Descriptor.new(:string, :indexed, :multivalued)
    end

    # Most interesting case because the suffixe produced depends on the type parameter 
    # produces suffixes:
    #  _tesim - for strings or text fields
    #  _dtsim - for dates
    #  _isim - for integers
    def self.searchable
      @searchable ||= Descriptor.new(searchable_field_definition, converter: searchable_converter, requires_type: true)
    end
    
    # Takes fields which are stored as strings, but we want indexed as dates.  (e.g. "November 6th, 2012")
    # produces suffixes:
    #  _dtsi - for dates
    def self.dateable
      @dateable ||= Descriptor.new(:date, :stored, :indexed, converter: dateable_converter)
    end

    # Produces a _ssim suffix
    def self.symbol
      @symbol ||= Descriptor.new(:string, :stored, :indexed, :multivalued)
    end

    # Produces a _ssi suffix
    def self.sortable
      @sortable ||= Descriptor.new(:string, :indexed, :stored)
    end

    # Produces a _ssm suffix
    def self.displayable
      @displayable ||= Descriptor.new(:string, :stored, :multivalued)
    end

    # Produces a _tim suffix (used to be _unstem)
    def self.unstemmed_searchable
      @unstemmed_searchable ||= Descriptor.new(:text, :indexed, :multivalued)
    end

    def self.simple
      @simple ||= Descriptor.new(lambda {|field_type| [field_type, :indexed]})
    end
    protected

    def self.searchable_field_definition
      lambda do |type|
        type = :text_en if [:string, :text].include?(type) # for backwards compatibility with old solr schema
        vals = [type, :indexed, :stored]
        vals << :multivalued unless type == :date
        vals
      end
    end

    def self.searchable_converter
      lambda do |type|
        case type
        when :date
          lambda { |val| iso8601_date(val)}
        end
      end
    end

    def self.dateable_converter
      lambda do |type|
        lambda do |val| 
          begin
            iso8601_date(Date.parse(val))
          rescue ArgumentError
            nil 
          end
        end
      end
    end
    

    def self.iso8601_date(value)
      begin 
        if value.is_a?(Date) 
          DateTime.parse(value.to_s).to_time.utc.iso8601 
        elsif !value.empty?
          DateTime.parse(value).to_time.utc.iso8601
        end
      rescue ArgumentError => e
        raise ArgumentError, "Unable to parse `#{value}' as a date-time object"
      end
    end
  end
end
