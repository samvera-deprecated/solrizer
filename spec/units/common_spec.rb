require 'spec_helper'

describe Solrizer::Common do
  before do
    class Foo
      include Solrizer::Common
    end
  end
  after do
     Object.send(:remove_const, :Foo)
  end

  it "should handle many field types" do
    solr_doc = {}
    Foo.create_and_insert_terms('my_name', 'value', [:displayable, :searchable, :sortable], solr_doc)
    solr_doc.should == {'my_name_ssm' => ['value'], 'my_name_si' => ['value'], 'my_name_teim' => ['value']}
  end
  
  it "should handle dates that are searchable" do
    solr_doc = {}
    Foo.create_and_insert_terms('my_name', Date.parse('2013-01-10'), [:stored_searchable], solr_doc)
    solr_doc.should == {'my_name_dtsim' => ['2013-01-10T00:00:00Z']}
  end

  it "should handle dates that are displayable" do
    solr_doc = {}
    Foo.create_and_insert_terms('my_name', Date.parse('2013-01-10'), [:displayable], solr_doc)
    solr_doc.should == {'my_name_ssm' => ['2013-01-10']}
  end

  it "should handle dates that are sortable" do
    solr_doc = {}
    Foo.create_and_insert_terms('my_name', Date.parse('2013-01-10'), [:sortable], solr_doc)
    solr_doc.should == {'my_name_si' => ['2013-01-10']}
  end
end
