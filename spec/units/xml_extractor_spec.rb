require 'spec_helper'

describe Solrizer::XML::Extractor do
  
  before do
    @extractor = Solrizer::Extractor.new
  end

  let(:result) { @extractor.xml_to_solr(fixture("druid-bv448hq0314-descMetadata.xml"))}
  
  describe ".xml_to_solr" do
    it "should turn simple xml into a solr document" do
      result[:type_tesim].should == "text"
      result[:medium_tesim].should == "Paper Document"
      result[:rights_tesim].should == "Presumed under copyright. Do not publish."
      result[:date_tesim].should == "1985-12-30"
      result[:format_tesim].should be_kind_of(Array)
      result[:format_tesim].should include("application/tiff")
      result[:format_tesim].should include("application/pdf")
      result[:format_tesim].should include("application/jp2000")
      result[:title_tesim].should == "This is a Sample Title"
      result[:publisher_tesim].should == "Sample Unversity"
    end
  end
  
end
