require 'spec_helper'

describe Solrizer::FieldNameMapper do
  
  before(:all) do
    class TestFieldNameMapper
      include Solrizer::FieldNameMapper
    end
  end
  
  describe "#mappings" do
    it "should return at least an id_field value" do
      TestFieldNameMapper.id_field.should == "id"
    end
  end
  
  describe '#solr_name' do
    it "should generate solr field names" do
      TestFieldNameMapper.solr_name(:active_fedora_model, :symbol).should == "active_fedora_model_ssim"
    end
  end
  
  describe ".solr_name" do
    it "should generate solr field names" do
      TestFieldNameMapper.new.solr_name(:active_fedora_model, :symbol).should == "active_fedora_model_ssim"
    end
  end
end
