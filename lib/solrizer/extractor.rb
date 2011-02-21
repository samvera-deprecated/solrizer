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

  # Deprecated.
  # merges input_hash into solr_hash
  # @param [Hash] input_hash the input hash of values
  # @param [Hash] solr_hash the solr values hash to add the values into
  # @return [Hash] the populated Solr values hash
  # 
  def extract_hash( input_hash, solr_hash=Hash.new )   
    warn "[DEPRECATION] `extract_hash` is deprecated.  Just pass values directly into your solr values hash" 
    return solr_hash.merge!(input_hash)
  end
  
end
end
