require "nokogiri"
require 'yaml'

module Solrizer::HTML::Extractor
  
  #
  # This method strips html tags out and returns content to be indexed in solr
  #
  # @param [Datastream] ds object that responds to .content with HTML content
  # @param [Hash] solr_doc hash of values to be inserted into solr as a solr document
  def html_to_solr( ds, solr_doc=Hash.new )
    
    text = CGI.unescapeHTML(ds.content)
    doc = Nokogiri::HTML(text)
    
    # html to story_display
    stories = doc.xpath('//story')
        
    stories.each do |story|
      solr_doc.merge!({:story_display => story.children.to_xml})
    end
    
    #strip out text and put in story_t
    text_nodes = doc.xpath("//text()")
    text = String.new
    
     text_nodes.each do |text_node|
       text << text_node.content
     end
    
     solr_doc.merge!({:story_t => text})
     
     return solr_doc
  end
  
end
