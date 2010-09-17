require File.join( File.dirname(__FILE__), "..", "spec_helper" )

# require 'solrizer'
# require 'solrizer/field_name_mapper'

def helper
  @test_instance
end

describe Solrizer::FieldNameMapper do
  
  before(:each) do
    @test_instance = Solrizer::FieldNameMapper
  end
  
  after(:all) do
    # Revert to default mappings after running tests
    silence do
      Solrizer::FieldNameMapper.load_mappings
    end
  end
  
  describe ".solr_names" do
    it "should generate solr field names from settings in solr_mappings" do
      helper.solr_names(:system_create, :date).should == [:system_create_dt]
    end
    it "should format the response based on the class of the input" do
      helper.solr_names(:system_create, :date).should == [:system_create_dt]
      helper.solr_names("system_create", :date).should == ["system_create_dt"]
    end
    it "should apply suffixes for index types" do
      helper.solr_names(:system_create, :date, [:facetable, :displayable]).should == [:system_create_dt, :system_create_facet, :system_create_display]
      helper.solr_names('system_create', :date, [:facetable, :displayable]).should == ['system_create_dt', 'system_create_facet', 'system_create_display']
    end
    it "should allow nil data type, so that" do
      helper.solr_names(:system_create, nil).should == []
      helper.solr_names(:system_create, nil, [:facetable, :displayable]).should == [:system_create_facet, :system_create_display]
    end
    it "should handle unknown data types" do
      silence do
        helper.solr_names(:system_create, :foo).should == []
        helper.solr_names(:system_create, :foo, [:facetable, :displayable]).should == [:system_create_facet, :system_create_display]
      end
    end
    it "should handle unknown index types" do
      silence do
        helper.solr_names(:system_create, :foo, [:bar]).should == []
        helper.solr_names(:system_create, :date, [:foo, :facetable, :bar]).should == [:system_create_dt, :system_create_facet]
      end
    end
    it "should rely on whichever mappings have been loaded into the SolrService" do
      helper.solr_names(:system_create, :date).should == [:system_create_dt]
      helper.solr_names(:foo, :text).should == [:foo_t]
      silence do
        Solrizer::FieldNameMapper.load_mappings(File.join(File.dirname(__FILE__), "..", "fixtures", "solr_mappings_af_0.1.yml"))
      end
      helper.solr_names(:system_create, :date).should == [:system_create_date]
      helper.solr_names(:foo, :text).should == [:foo_field]
    end
  end
  
  def silence
    old_level = helper.logger.level
    helper.logger.level = 100
    begin
      yield
    ensure
      helper.logger.level = old_level
    end
  end
end
