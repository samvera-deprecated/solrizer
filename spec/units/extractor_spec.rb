require 'spec_helper'

describe Solrizer::Extractor do
  
  before(:all) do
    @extractor = Solrizer::Extractor.new
  end
  
  describe ".format_node_value" do
    it "should strip white space out of the array and join it with a single blank" do
      expect(Solrizer::Extractor.format_node_value([" test    \n   node    \t value \t"])).to eq "test node value"
      expect(Solrizer::Extractor.format_node_value([" test ", "     \n   node ", "   \t value \t"])).to eq "test node value"
    end
    it "should return an empty string if given an argument of nil" do
      expect(Solrizer::Extractor.format_node_value(nil)).to eq '' 
    end

    it "should strip white space out of a string" do
      expect(Solrizer::Extractor.format_node_value("raw  string\n with whitespace")).to eq "raw string with whitespace"
    end
  end

  describe "#insert_solr_field_value" do
    it "should initialize a solr doc list if it is nil" do
       solr_doc = {'title_tesim' => nil }
       Solrizer::Extractor.insert_solr_field_value(solr_doc, 'title_tesim', 'Frank')
       expect(solr_doc).to eq("title_tesim"=>"Frank")
    end
    it "should insert multiple" do
       solr_doc = {'title_tesim' => nil }
       Solrizer::Extractor.insert_solr_field_value(solr_doc, 'title_tesim', 'Frank')
       Solrizer::Extractor.insert_solr_field_value(solr_doc, 'title_tesim', 'Margret')
       Solrizer::Extractor.insert_solr_field_value(solr_doc, 'title_tesim', 'Joyce')
       expect(solr_doc).to eq("title_tesim"=>["Frank", 'Margret', 'Joyce'])
    end
    it "should not make a list if a single valued field is passed in" do
       solr_doc = {}
       Solrizer::Extractor.insert_solr_field_value(solr_doc, 'title_dtsi', '2013-03-22T12:33:00Z')
       expect(solr_doc).to eq("title_dtsi"=>"2013-03-22T12:33:00Z")
    end

  end
  
end
