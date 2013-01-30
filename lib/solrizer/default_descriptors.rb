module Solrizer
  module DefaultDescriptors

    # The suffix produced depends on the type parameter -- produces suffixes:
    #  _tesim - for strings or text fields
    #  _dtsim - for dates
    #  _isim - for integers
    # Note that searchable fields are also stored for backwards compatibilitiy 
    #   TODO:  make a searchable and stored field type  ("searchable_and_displayable" like "search and destroy"?  "displearchable" ?)
    #     and then make searchable not stored.
    def self.searchable
      @searchable ||= Descriptor.new(searchable_field_definition, converter: searchable_converter, requires_type: true)
    end
    
    # Takes fields which are stored as strings, but we want indexed as dates.  (e.g. "November 6th, 2012")
    # produces suffixes:
    #  _dtsi - for dates
    def self.dateable
      @dateable ||= Descriptor.new(:date, :stored, :indexed, :multivalued, converter: dateable_converter)
    end

    # Produces _sim suffix
    def self.facetable
      @facetable ||= Descriptor.new(:string, :indexed, :multivalued)
    end

    # Produces _ssim suffix;  should probably be deprecated
    def self.symbol
      @symbol ||= Descriptor.new(:string, :stored, :indexed, :multivalued)
    end

    # Produces _si suffix
    def self.sortable
      @sortable ||= Descriptor.new(:string, :indexed)
    end

    # Fields that are both stored and sortable
    # Produces _ssi suffix if field_type is string
    # Produces _dtsi suffix if field_type is date
    def self.stored_sortable
      @stored_sortable ||= Descriptor.new(lambda {|field_type| [field_type, :stored, :indexed]}, converter: searchable_converter)
    end

    # Produces _ssm suffix
    def self.displayable
      @displayable ||= Descriptor.new(:string, :stored, :multivalued)
    end

    # Produces _tim suffix (used to be _unstem)
    def self.unstemmed_searchable
      @unstemmed_searchable ||= Descriptor.new(:text, :indexed, :multivalued)
    end

    def self.simple
      @simple ||= Descriptor.new(lambda {|field_type| [field_type, :indexed]})
    end
    protected

    # note that searchable fields are also stored.  Probably should change that at some point
    def self.searchable_field_definition
      lambda do |type|
        type = :text_en if [:string, :text].include?(type) # for backwards compatibility with old solr schema
        vals = [type, :indexed, :stored, :multivalued]
        vals
      end
    end

    def self.searchable_converter
      lambda do |type|
        case type
        when :date, :time
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
        if value.is_a?(Date) || value.is_a?(Time)
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
