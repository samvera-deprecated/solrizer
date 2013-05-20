require 'spec_helper'

describe Solrizer::Extractor do
  
  before(:all) do
    @extractor = Solrizer::Extractor.new
  end
  
  describe ".format_node_value" do
    it "should strip white space out of the array and join it with a single blank" do
      Solrizer::Extractor.format_node_value([" test    \n   node    \t value \t"]).should == "test node value"
      Solrizer::Extractor.format_node_value([" test ", "     \n   node ", "   \t value \t"]).should == "test node value"
    end
    it "should return an empty string if given an argument of nil" do
      Solrizer::Extractor.format_node_value(nil).should == ""
    end

    it "should strip white space out of a string" do
      Solrizer::Extractor.format_node_value("raw  string\n with whitespace").should == "raw string with whitespace"
    end

    it 'should handle date fields' do
      date = Date.civil(2011,12,01)
      Solrizer::Extractor.format_node_value(date).should == date.to_time.utc.iso8601.to_s
    end
  end

  describe "#insert_solr_field_value" do
    it "should initialize a solr doc list if it is nil" do
       solr_doc = {'title_tesim' => nil }
       Solrizer::Extractor.insert_solr_field_value(solr_doc, 'title_tesim', 'Frank')
       solr_doc.should == {"title_tesim"=>"Frank"}
    end
    it "should insert multiple" do
       solr_doc = {'title_tesim' => nil }
       Solrizer::Extractor.insert_solr_field_value(solr_doc, 'title_tesim', 'Frank')
       Solrizer::Extractor.insert_solr_field_value(solr_doc, 'title_tesim', 'Margret')
       Solrizer::Extractor.insert_solr_field_value(solr_doc, 'title_tesim', 'Joyce')
       solr_doc.should == {"title_tesim"=>["Frank", 'Margret', 'Joyce']}
    end
    it "should not make a list if a single valued field is passed in" do
       solr_doc = {}
       Solrizer::Extractor.insert_solr_field_value(solr_doc, 'title_dtsi', '2013-03-22T12:33:00Z')
       solr_doc.should == {"title_dtsi"=>"2013-03-22T12:33:00Z"}
    end

  end
  
end
