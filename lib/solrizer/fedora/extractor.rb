require 'solr'
require 'rexml/document'
require "nokogiri"
require 'yaml'

module Solrizer::Fedora::Extractor

  #
  # Extracts content-model and hydra-type from RELS-EXT datastream
  #
  def extract_rels_ext( text, solr_doc=Solr::Document.new )
    # TODO: only read in this file once
    
    if defined?(RAILS_ROOT)
      config_path = File.join(RAILS_ROOT, "config")
    else
      config_path = File.join(File.dirname(__FILE__), "..", "..", "..", "config")
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
  
end
