require 'solr'
require 'rexml/document'
require "nokogiri"
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
  #
  def xml_to_solr( text, solr_doc=Solr::Document.new )
    doc = REXML::Document.new( text )
    doc.root.elements.each do |element|
      solr_doc << Solr::Field.new( :"#{element.name}_t" => "#{element.text}" )
    end

    return solr_doc
  end
  
end
