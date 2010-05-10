require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'shelver'

describe Shelver::Indexer do
  
  before(:each) do
    @indexer = Shelver::Indexer.new
  end
  
  describe "shelve_object" do
    it "should update solr with the metadata from the given object" do
      pending "Got to decide if/how to handle fixtures in this gem. Probably should just mock out Fedora & Solr entirely."
      obj = Shelver::Repository.get_object( "druid:sb733gr4073" )
      @indexer.index( obj )
    end
  end
  
end