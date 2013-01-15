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
    directive = Solrizer::Directive.new(:string, [:displayable, :searchable, :sortable] )
    Foo.create_and_insert_terms('my_name', 'value', directive, solr_doc)
    solr_doc.should == {'my_name_t' => ['value'], 'my_name_sort' => ['value'], 'my_name_display' => ['value']}
  end
  it "should handle dates that are searchable" do
    solr_doc = {}
    directive = Solrizer::Directive.new(:date, [:searchable] )
    Foo.create_and_insert_terms('my_name', Date.parse('2013-01-10'), directive, solr_doc)
    solr_doc.should == {'my_name_dt' => ['2013-01-10T00:00:00Z']}
  end

  it "should handle dates that are displayable" do
    solr_doc = {}
    directive = Solrizer::Directive.new(:date, [:displayable])
    Foo.create_and_insert_terms('my_name', Date.parse('2013-01-10'), directive, solr_doc)
    solr_doc.should == {'my_name_display' => ['2013-01-10']}
  end
end
