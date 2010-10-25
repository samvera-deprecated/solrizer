require 'solr'
require 'rexml/document'
require "nokogiri"
require 'yaml'

module Solrizer::HTML::Extractor
  
  #
  # This method strips html tags out and returns content to be indexed in solr
  #
  def html_to_solr( ds, solr_doc=Solr::Document.new )
    
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
