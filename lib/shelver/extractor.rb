require 'solr'
require 'rexml/document'
require "nokogiri"
require 'yaml'
#require 'descriptor.rb'
TEXT_FORMAT_ALTO = 0

module Shelver
class Extractor
  
  #
  # This method extracts keywords from the given text based on the text format
  #
  def extractFullText( text, text_format=TEXT_FORMAT_ALTO )
    keywords = String.new
    if( text_format == TEXT_FORMAT_ALTO )
      keywords = extractFullTextFromAlto( text )
    end
    #keywords.join( " " )
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
    doc = text.class==REXML::Document ? text : REXML::Document.new( text )

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
    doc = REXML::Document.new( text )
    #loc_info = extract_location_info( doc ) 
    #loc_info[:facets].merge! extract_facets( doc )
    loc_info = extract_facets( doc )
    return loc_info
  end
  
  def extract_location( text )
     doc = Nokogiri::XML( text )
     
     symbols = Hash[]
     facets = Hash[]
     
     symbols['series'] = doc.search("//c01[@level = 'series']/did/unittitle").first.content unless doc.search("//c01[@level = 'series']/did/unittitle").first.nil?
     symbols['subseries'] = doc.search("//c02[@level = 'subseries']/did/unittitle").first.content unless doc.search("//c02[@level = 'subseries']/did/unittitle").first.nil?
     symbols['box'] = doc.search("//c03[@level = 'file']/did/container[@type = 'box']").first.content unless doc.search("//c03[@level = 'file']/did/container[@type = 'box']").first.nil?
     symbols['folder'] = doc.search("//c03[@level = 'file']/did/container[@type = 'folder']").first.content unless doc.search("//c03[@level = 'file']/did/container[@type = 'folder']").first.nil?
     symbols['title'] = doc.search("//c03[@level = 'file']/did/unittitle/text()").first.content unless doc.search("//c03[@level = 'file']/did/unittitle/text()").first.nil?
     symbols['date'] = doc.search("//c03[@level = 'file']/did/unittitle/unitdate").first.content unless doc.search("//c03[@level = 'file']/did/unittitle/unitdate").first.nil?
     
     facets['series'] = symbols['series']
     facets['subseries'] = symbols['subseries']
     facets['box'] = symbols['box']
     facets['folder'] = symbols['folder']
     facets['title'] = symbols['title']
     facets['date'] = symbols['date']
     
     return Hash[:facets => facets, :symbols=> symbols]
     
  end
  
  def extract_tags(text)
    doc = REXML::Document.new( text )
    extract_tag(doc, 'archivist_tags').merge(extract_tag(doc, 'donor_tags'))
  end
  
  def extract_tag(doc, type)
    tags = doc.elements["/fields/#{type}"]
    return {} unless tags
    {type => tags.text.split(/,/).map {|t| t.strip}}
  end

  

  # Extracts series, box, folder and collection info into facets, fixing some of the info when necessary
  # Uses title info from EAD descriptor to populate the facet values when possible
  # @returns facets and symbol fields in format {:facets=>{...}, :symbols=>{...}}
  # @text an XML document
  
  def extract_location_info( text )
    # initialize XML document for parsing
    doc = text.class==REXML::Document ? text : REXML::Document.new( text )
    
    
    descriptor = Descriptor.retrieve("sc0340")
    symbols = Hash[]
    
    doc.elements.each( '/document/facets/facet[@type="sourcelocation"]' ) do |element|
      doc = element.text
      if doc.include?("Folder")
        symbols['folder'] = element.text
      elsif doc.include?("Box")
        symbols['box'] = element.text
      elsif doc.include?("eaf7000")
        symbols['series'] = element.text
      end
    end
    
    series_id = symbols['series'] == "eaf7000" ? "Accession 2005-101>" : hash['series']
    folder_id = symbols['folder'].gsub("Folder ", "")
    box_id = symbols['box'].gsub("Box ", "")

    subseries_xpath_query = "//c01[did/unittitle=\"#{series_id}\"]/c02[c03/did[container[@type=\"box\"]=\'#{box_id}\' and container[@type=\"folder\"]=\'#{folder_id}\']]"
     
    subseries = descriptor.xpath( subseries_xpath_query )
        
    facets = Hash[]
    facets['folder'] = ead_folder_title( series_id, box_id, folder_id ) 
    facets['box'] = symbols['box']
    facets['subseries'] = subseries.search("unittitle").first.content unless subseries.search("unittitle").first.nil?
    facets['series'] = series_id
    facets['collection'] = "Edward A. Feigenbaum Papers"
    return Hash[:facets => facets, :symbols=> symbols]
    
  end
  
  #
  # This method extracts all keywords from the given ALTO text
  #
  def extractFullTextFromAlto( text )
    # initialize XML document for parsing
    #doc = REXML::Document.new( text )
        doc = Nokogiri::XML(text)

    # extract all keywords from ALTO attributes
    keywords = String.new
#    doc.elements.each( '//String/@CONTENT' ) do |element|
    doc.xpath( '//String/@CONTENT' ).each do |element|
      keywords << element.text
    end
    return keywords
  end
  
  #
  # Extracts content-model and hydra-type from RELS-EXT datastream
  #
  def extract_rels_ext( text, solr_doc=Solr::Document.new )
    # TODO: only read in this file once
    map = YAML.load(File.open(File.join(Rails.root, "config/hydra_types.yml")))
    
    doc = Nokogiri::XML(text)
    doc.xpath( '//foo:hasModel', 'foo' => 'info:fedora/fedora-system:def/model#' ).each do |element|
      cmodel = element.attributes['resource'].to_s
      solr_doc << Solr::Field.new( :cmodel_t => cmodel )
      
      if map.has_key?(cmodel)
        solr_doc << Solr::Field.new( :hydra_type_t => map[cmodel] )
      end
    end

    return solr_doc
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
  
  #
  # This method strips html tags out and returns content to be indexed in solr
  #
  def html_content_to_solr( ds, solr_doc=Solr::Document.new )
    
    text = CGI.unescapeHTML(ds.content)
    doc = Nokogiri::HTML(text)
    
    # html to story_display
    stories = doc.xpath('//story')
        
    stories.each do |story|
      solr_doc << Solr::Field.new(:story_display => story.children.to_xml)
    end
    
    #strip out text and put in story_t
    text_nodes = doc.xpath("//text()")
    text = String.new
    
     text_nodes.each do |text_node|
       text << text_node.content
     end
    
     solr_doc << Solr::Field.new(:story_t => text)
     
     return solr_doc
  end
  
  
  # Returns the title for a folder given a series, box and folder
  # Appends the folder number to the title for easy sorting
  def ead_folder_title(series, box, folder, ead_description=@descriptor) 
      if folder.to_s.match(/^[0-9]*:/)
        return folder
      else
        series_id = series == "eaf7000" ? "Accession 1986-052>" : series.to_s
        folder_id = folder.to_s.gsub("Folder ", "")
        box_id = box.to_s.gsub("Box ", "")
        #puts "Series id: " + series_id + "; Box id: " + box_id + "; Folder id: " + folder_id
        unittitle_query = "//c01[did/unittitle=\"#{series_id}\"]//did[container[@type=\"box\"]=\'#{box_id}\' and container[@type=\"folder\"]=\'#{folder_id}\']/unittitle"
        
        #xpath_query = "//dsc[@type=\"in-depth\"]/c01[did/unittitle=\"#{series_id}\"]/c02/c03/did[container[@type=\"box\"]=#{box_id} and container[@type=\"folder\"]=#{folder_id}]/unittitle"
        unittitle_node = ead_description.xpath( unittitle_query ).first
        if unittitle_node.nil?
          #return "Series id: " + series_id + "; Box id: " + box_id + "; Folder id: " + folder_id
          return "#{folder_id}: Folder #{folder_id}"
        else
          return folder_id + ": " + unittitle_node.content
        end
      end
    end
    
  private :extractFullTextFromAlto

end
end
