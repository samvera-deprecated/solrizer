require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'solrizer'

describe Solrizer::Fedora::Extractor do
  
  before(:all) do
    @extractor = Solrizer::Extractor.new
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