require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Solrizer::FieldNameMapper do
  
  before(:all) do
    class TestFieldNameMapper
      include Solrizer::FieldNameMapper
    end
  end
  
  describe "#mappings" do
    it "should return at least an id_field value" do
      Solrizer::FieldNameMapper.mappings["id"].should == "id"
    end
  end
  
  describe '#solr_name' do
    it "should generate solr field names" do
      Solrizer::FieldNameMapper.solr_name(:active_fedora_model, :symbol).should == "active_fedora_model_s"
    end
  end
  
  describe ".solr_name" do
    it "should generate solr field names" do
      TestFieldNameMapper.new.solr_name(:active_fedora_model, :symbol).should == "active_fedora_model_s"
    end
  end
end