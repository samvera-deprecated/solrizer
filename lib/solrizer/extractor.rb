require 'solr'
require 'rexml/document'
require "nokogiri"
require 'yaml'

module Solrizer
  
# Provides utilities for extracting solr fields from a variety of objects and/or creating solr documents from a given object
# Note: These utilities are optional.  You can implement .to_solr directly on your classes if you want to bypass using Extractors.
#
# Each of the Solrizer implementations provides its own Extractor module that extends the behaviors of Solrizer::Extractor
# with methods specific to that implementation (ie. extract_tag, extract_rels_ext, xml_to_solr, html_to_solr)
#
class Extractor

  # Populates a solr doc with values from a hash.  
  # Accepts two forms of hashes:
  # => {'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]}
  # or
  # => {:facets => {'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]} }
  #
  # Note that values for individual fields can be a single string or an array of strings.
  def extract_hash( input_hash, solr_doc=Solr::Document.new )    
    facets = input_hash.has_key?(:facets) ? input_hash[:facets] : input_hash
    facets.each_pair do |facet_name, value|
      case value.class.to_s
      when "String"
        solr_doc << Solr::Field.new( :"#{facet_name}_facet" => "#{value}" )
      when "Array"
        value.each { |v| solr_doc << Solr::Field.new( :"#{facet_name}_facet" => "#{v}" ) } 
      end
    end
    
    if input_hash.has_key?(:symbols) 
      input_hash[:symbols].each do |symbol_name, value|
        case value.class.to_s
        when "String"
          solr_doc << Solr::Field.new( :"#{symbol_name}_s" => "#{value}" )
	      when "Array"
          value.each { |v| solr_doc << Solr::Field.new( :"#{symbol_name}_s" => "#{v}" ) } 
        end
      end
    end
    return solr_doc
  end
  
end
end
