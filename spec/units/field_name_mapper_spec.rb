require File.join( File.dirname(__FILE__), "..", "spec_helper" )

# require 'solrizer'
# require 'solrizer/field_name_mapper'

class FieldNameMapperTest
  include Solrizer::FieldNameMapper
end

def helper
  @test_instance
end

describe Solrizer::FieldNameMapper do
  
  before(:each) do
    @test_instance = FieldNameMapperTest.new
  end
  
  after(:all) do
    # Revert to default mappings after running tests
    Solrizer::FieldNameMapper.load_mappings
  end
  
  describe ".solr_name" do
    it "should generate solr field names from settings in solr_mappings" do
      helper.solr_name(:system_create, :date).should == :system_create_dt
    end
    it "should format the response based on the class of the input" do
      helper.solr_name(:system_create, :date).should == :system_create_dt
      helper.solr_name("system_create", :date).should == "system_create_dt"
    end
    it "should rely on whichever mappings have been loaded into the SolrService" do
      helper.solr_name(:system_create, :date).should == :system_create_dt
      helper.solr_name(:foo, :text).should == :foo_t
      Solrizer::FieldNameMapper.load_mappings(File.join(File.dirname(__FILE__), "..", "fixtures", "solr_mappings_af_0.1.yml"))
      helper.solr_name(:system_create, :date).should == :system_create_date
      helper.solr_name(:foo, :text).should == :foo_field
    end
  end
end