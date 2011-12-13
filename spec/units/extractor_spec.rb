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
  end
  
end
