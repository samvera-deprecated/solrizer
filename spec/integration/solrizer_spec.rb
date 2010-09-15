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

  

  
end