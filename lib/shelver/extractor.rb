require 'solr'
require 'rexml/document'
require "nokogiri"
require 'yaml'
#require 'descriptor.rb'
TEXT_FORMAT_ALTO = 0

module Shelver
class Extractor
  
  
  def extract_tags(text)
    doc = REXML::Document.new( text )
    extract_tag(doc, 'archivist_tags').merge(extract_tag(doc, 'donor_tags'))
  end
  
  def extract_tag(doc, type)
    tags = doc.elements["/fields/#{type}"]
    return {} unless tags
    {type => tags.text.split(/,/).map {|t| t.strip}}
  end

  
  #
  # Extracts content-model and hydra-type from RELS-EXT datastream
  #
  def extract_rels_ext( text, solr_doc=Solr::Document.new )
    # TODO: only read in this file once
    
    if defined?(RAILS_ROOT)
      config_path = File.join(RAILS_ROOT, "config")
    else
      config_path = File.join(File.dirname(__FILE__), "..", "..", "config")
    end    
    map = YAML.load(File.open(File.join(config_path, "hydra_types.yml")))
    
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
  
end
end
