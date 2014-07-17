require 'spec_helper'

describe Solrizer::XML::Extractor do
  
  before do
    @extractor = Solrizer::Extractor.new
  end

  let(:result) { @extractor.xml_to_solr(fixture("druid-bv448hq0314-descMetadata.xml"))}
  
  describe ".xml_to_solr" do
    it "should turn simple xml into a solr document" do
      expect(result[:type_tesim]).to eq "text"
      expect(result[:medium_tesim]).to eq "Paper Document"
      expect(result[:rights_tesim]).to eq "Presumed under copyright. Do not publish."
      expect(result[:date_tesim]).to eq "1985-12-30"
      expect(result[:format_tesim]).to be_kind_of(Array)
      expect(result[:format_tesim]).to include("application/tiff")
      expect(result[:format_tesim]).to include("application/pdf")
      expect(result[:format_tesim]).to include("application/jp2000")
      expect(result[:title_tesim]).to eq "This is a Sample Title"
      expect(result[:publisher_tesim]).to eq "Sample Unversity"
    end
  end
  
end
