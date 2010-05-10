require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'solrizer'

describe Solrizer::Indexer do
  
  before(:each) do
    @indexer = Solrizer::Indexer.new
  end
  
  describe "index" do
    it "should update solr with the metadata from the given object" do
      pending "Got to decide if/how to handle fixtures in this gem. Probably should just mock out Fedora & Solr entirely."
      obj = Solrizer::Repository.get_object( "druid:sb733gr4073" )
      @indexer.index( obj )
    end
  end
  
end