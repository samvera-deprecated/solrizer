require 'solr'
require 'rexml/document'
require 'descriptor'

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
  # DEPRECATED: Use extract_facets instead
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
    
    facets.merge! extract_location_info( doc )[:facets]

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

    return facets
  end
  
  def extract_ext_properties( text )
    extract_facets( text ).merge! extract_location_info( text )
  end

  # Extracts series, box, folder and collection info into facets, fixing some of the info when necessary
  # Uses title info from EAD descriptor to populate the facet values when possible
  # @returns facets and symbol fields in format {:facets=>{...}, :symbols=>{...}}
  # @doc a REXML document
  def extract_location_info( doc )
    
    descriptor = Descriptor.retrieve("sc0340")
    symbols = Hash[]
    
    doc.elements.each( '/document/facets/facet[@type="sourcelocation"]' ) do |element|
      text = element.text
      if text.include?("Folder")
        symbols['folder'] = element.text
      elsif text.include?("Box")
        symbols['box'] = element.text
      elsif text.include?("eaf7000")
        symbols['series'] = element.text
      end
    end
    
    series_id = symbols['series'] == "eaf7000" ? "Accession 2005-101>" : hash['series']
    folder_id = symbols['folder'].gsub("Folder ", "")
    box_id = symbols['box'].gsub("Box ", "")
    # box_id = "51"
    # folder_id = "5"
    #container_xpath_query = "//dsc[@type=\"in-depth\"]/c01[did/unittitle=\"#{series_id}\"]/c02/c03/did[container[@type=\"box\"]=#{box_id} and container[@type=\"folder\"]=#{folder_id}]/unittitle"
    #container_xpath_query = "//dsc[@type=\"in-depth\"]/c01[did/unittitle=\"#{series_id}\"]//container[@type=\"box\"]=\"#{box_id}\""
    container_xpath_query = "//c01[did/unittitle=\"#{series_id}\"]//did[container[@type=\"box\"]=\'#{box_id}\' and container[@type=\"folder\"]=\'#{folder_id}\']"
    subseries_xpath_query = "//c01[did/unittitle=\"#{series_id}\"]/c02[c03/did[container[@type=\"box\"]=\'#{box_id}\' and container[@type=\"folder\"]=\'#{folder_id}\']]"
     
    # puts "Query: #{container_xpath_query}"
    container = descriptor.xpath( container_xpath_query )
    subseries = descriptor.xpath( subseries_xpath_query )
    
    # puts "Container: #{container}"
    #puts "Unittitle: #{container.search("unittitle").first.content}"
    # puts "Subseries: #{subseries}"
    # puts "Subseries title: #{subseries.search("unittitle").first.content}"
        
    facets = Hash[]
    facets['folder'] = container.search("unittitle").first.nil? ? symbols["folder"] : container.search("unittitle").first.content
    facets['box'] = symbols['box']
    facets['subseries'] = subseries.search("unittitle").first.nil? ? "" : subseries.search("unittitle").first.content
    facets['series'] = series_id
    facets['collection'] = "Edward A. Feigenbaum Papers"
    return Hash[:facets => facets, :symbols=> symbols]
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

