require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/shelver/extractor'

describe Shelver::Extractor do
  
  before(:each) do
    @extractor = Shelver::Extractor.new
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
  
  describe "extract_rels_ext" do 
    it "should extract the content model of the RELS-EXT datastream of a Fedora object and set hydra_type using hydra_types mapping" do
      rels_ext = fixture("rels_ext_cmodel.xml")
      result = @extractor.extract_rels_ext( rels_ext )
      result[:cmodel_t].should == "info:fedora/fedora-system:ContentModel-3.0"
      result[:hydra_type_t].should == "salt_document"
      
      # ... and a hacky way of making sure that it added a field for each of the dc:medium values
      result.inspect.include?('@value="info:fedora/afmodel:SaltDocument"').should be_true
      result.inspect.include?('@value="jp2_document"').should be_true
    end
  end
  
  describe "extract_hydra_types" do 
    it "should extract the hydra_type of a Fedora object" do
      rels_ext = fixture("rels_ext_cmodel.xml")
      result = @extractor.extract_rels_ext( rels_ext )
      result[:hydra_type_t].should == "salt_document"
    end
  end
  
  
end