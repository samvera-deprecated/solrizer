require 'solr'
require 'rexml/document'
require "nokogiri"
require "xmlsimple"
require 'yaml'

module Solrizer::XML::Extractor
  
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
  # This method extracts solr fields from simple xml
  # If you want to do anything more nuanced with the xml, use TerminologyBasedSolrizer instead.
  #
  # @param [xml] text xml content to index
  # @param [Hash] solr_doc
  def xml_to_solr( text, solr_doc=Hash.new )
    doc = XmlSimple.xml_in( text )
    
    doc.each_pair do |name, value|
      if value.kind_of?(Array) 
        if value.first.kind_of?(Hash)
          # This deals with the way xml-simple handles nodes with attributes
          solr_doc.merge!({:"#{name}_t" => "#{value.first["content"]}"})
        elsif value.length > 1
          solr_doc.merge!({:"#{name}_t" => value})
        else
          solr_doc.merge!({:"#{name}_t" => "#{value}"})
        end
      else
        solr_doc.merge!({:"#{name}_t" => "#{value}"})
      end
    end

    return solr_doc
  end
  
end
