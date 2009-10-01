
require 'rexml/document'

TEXT_FORMAT_ALTO = 0

class Extractor

  #
  # This method extracts keywords from the given text based on the text format
  #
  def extractFullText( text, text_format=TEXT_FORMAT_ALTO )
    keywords = String.new
    if( text_format == TEXT_FORMAT_ALTO )
      keywords = extractFullTextFromAlto( text )
    end
    keywords.join( " " )
  end

  #
  # This method extracts facet categories from the given text and return a hash containing all the facets
  #
  def extractFacetCategories( text )
    # initialize XML document for parsing
    doc = REXML::Document.new( text )

    # extract all facet categories and facet data from the XML attributes
    facets = Hash.new
    doc.elements.each( '/document/attributes/attribute' ) do |element|
      element_data = element.text
      type_attr = element.attribute( "type" ).to_s
      if( type_attr =~ /title/ )
        facets['title'] = element_data
      elsif( type_attr =~ /year/ )
        facets['year'] = element_data
      end
    end

    doc.elements.each( '/document/facets/facet' ) do |element|
      element_data = element.text
      type_attr = element.attribute( "type" ).to_s
      if( type_attr =~ /technology/ )
        facets['technology'] = element_data
      elsif( type_attr =~ /company/ )
        facets['company'] = element_data
      elsif( type_attr =~ /person/ )
        facets['person'] = element_data
      elsif( type_attr =~ /organization/ )
        facets['organization'] = element_data
      elsif( type_attr =~ /city/ )
        facets['city'] = element_data
      elsif( type_attr =~ /provinceorstate/ )
        facets['state'] = element_data
      end
    end

    return facets
  end

  #
  # This method extracts all keywords from the given ALTO text
  #
  def extractFullTextFromAlto( text )
    # initialize XML document for parsing
    doc = REXML::Document.new( text )

    # extract all keywords from ALTO attributes
    keywords = String.new
    doc.elements.each( '//String/@CONTENT' ) do |element|
      keywords << element.text
    end
  end

  private :extractFullTextFromAlto

end

