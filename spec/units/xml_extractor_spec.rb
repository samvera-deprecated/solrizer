require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'solrizer'

describe Solrizer::XML::Extractor do
  
  before(:all) do
    @extractor = Solrizer::Extractor.new
  end
  
  describe ".xml_to_solr" do
    it "should turn simple xml into a solr document" do
      desc_meta = fixture("druid-bv448hq0314-descMetadata.xml")
      result = @extractor.xml_to_solr(desc_meta)
      result[:type_t].should == "text"
      result[:medium_t].should == "Paper Document"
      result[:rights_t].should == "Presumed under copyright. Do not publish."
      result[:date_t].should == "1985-12-30"
      result[:format_t].should == "application/tiff"
      result[:title_t].should == "This is a Sample Title"
      result[:publisher_t].should == "Sample Unversity"

      # ... and a hacky way of making sure that it added a field for each of the dc:medium values
      result.inspect.include?('@value="application/tiff"').should be_true
      result.inspect.include?('@value="application/pdf"').should be_true
    end
  end
  
end