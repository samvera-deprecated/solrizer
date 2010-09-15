require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'solrizer'

describe Solrizer::Indexer do
  
  before(:each) do
    @indexer = Solrizer::Indexer.new
    @obj = ActiveFedora::Base.new
    @obj.save
  end

  after(:each) do
    @obj.delete
  end
  
  describe "index" do
    it "should update solr with the metadata from the given object" do
      pending "Got to decide if/how to handle fixtures in this gem. Probably should just mock out Fedora & Solr entirely."
      obj = Solrizer::Repository.get_object( "druid:sb733gr4073" )
      @indexer.index( obj )
    end
  end

  describe "deleteDocument" do
    it "should delete a document from solr" do
      #make sure it is indexed
      obj = Solrizer::Repository.get_object( @obj.pid )
      @indexer.index( obj )
      #verify it is there
      puts "\r\n\r\n#{obj.pid}\r\n\r\n"
      id = obj.pid.gsub(/(:)/, '\\:')
      solr_results = @indexer.connection.query( "#{SOLR_DOCUMENT_ID}:#{id}" )
      solr_results.hits.size.should == 1
      solr_results.hits.first[SOLR_DOCUMENT_ID].should == obj.pid
      #delete it
      @indexer.deleteDocument(obj.pid)
      #verify it does not exist
      solr_results = @indexer.connection.query( "#{SOLR_DOCUMENT_ID}:#{id}" )
      solr_results.hits.size.should == 0
    end 
  end
  
end