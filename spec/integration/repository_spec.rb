require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'solrizer'

describe Solrizer::Repository do
  before(:all) do
    #create indexer so that Fedora and solr initialized
    @indexer = Solrizer::Indexer.new
  end

  before(:each) do

    class MockModel < ActiveFedora::Base
    end
    @obj = MockModel.new
    @obj.save
  end

  after(:each) do
    @obj.delete
  end

  describe "get_object" do
    it "should get an object with the actual model class and not just ActiveFedora::Base" do
      obj = Solrizer::Repository.get_object(@obj.pid)
      obj.pid.should == @obj.pid
      obj.class.should == MockModel
      obj.relationships.should == @obj.relationships
    end

    it "should just return ActiveFedora:Base object if the hasModel class is not known" do
      #rely on object being there that has a class not defined within the scope of this spec
      Object.send(:remove_const, :MockModel)
      obj = Solrizer::Repository.get_object(@obj.pid)
      obj.pid.should == @obj.pid
      obj.class.should == ActiveFedora::Base
    end
  end

  
end