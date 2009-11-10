require 'solr'
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
    
    facets.merge! extract_location_info( doc )

    return facets
  end
  
  def extract_facets( text )
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
        facets['technology'] ||= []
        facets['technology'] << element_data
      elsif( type_attr =~ /company/ )
        facets['company'] ||= []
        facets['company'] << element_data
      elsif( type_attr =~ /person/ )
        facets['person'] ||= []
        facets['person'] << element_data
      elsif( type_attr =~ /organization/ )
        facets['organization'] ||= []
        facets['organization'] << element_data
      elsif( type_attr =~ /city/ )
        facets['city'] ||= []
        facets['city'] << element_data
      elsif( type_attr =~ /provinceorstate/ )
        facets['state'] ||=[]
        facets['state'] << element_data
      end
    end
    
    facets.merge! extract_location_info( doc )

    return facets
  end

  # Extracts series, box, folder and collection info into facets, fixing some of the info when necessary
  # @doc a REXML document
  def extract_location_info( doc )
    hash = Hash[]
    doc.elements.each( '/document/facets/facet[@type="sourcelocation"]' ) do |element|
      text = element.text
      if text.include?("Folder")
        hash['folder'] = element.text
      elsif text.include?("Box")
        hash['box'] = element.text
      elsif text.include?("eaf7000")
        hash['series'] = element.text
      end
    end
    hash['collection'] = "e-a-feigenbaum-collection"
    return hash
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

  #
  # This method extracts solr fields from simple xml
  #
  def xml_to_solr( text, solr_doc=Solr::Document.new )
    doc = REXML::Document.new( text )
    doc.root.elements.each do |element|
      solr_doc << Solr::Field.new( :"#{element.name}_t" => "#{element.text}" )
    end
    return solr_doc
  end
  
  private :extractFullTextFromAlto

end

