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

  let(:solr_doc) { {} }

  it "should handle many field types" do
    Foo.create_and_insert_terms('my_name', 'value', [:displayable, :searchable, :sortable], solr_doc)
    expect(solr_doc).to eq('my_name_ssm' => ['value'], 'my_name_si' => 'value', 'my_name_teim' => ['value'])
  end

  it "should handle dates that are searchable" do
    Foo.create_and_insert_terms('my_name', Date.parse('2013-01-10'), [:stored_searchable], solr_doc)
    expect(solr_doc).to eq('my_name_dtsim' => ['2013-01-10T00:00:00Z'])
  end

  it "should handle dates that are stored_sortable" do
    Foo.create_and_insert_terms('my_name', Date.parse('2013-01-10'), [:stored_sortable], solr_doc)
    expect(solr_doc).to eq('my_name_dtsi' => '2013-01-10T00:00:00Z')
  end

  it "should handle dates that are displayable" do
    Foo.create_and_insert_terms('my_name', Date.parse('2013-01-10'), [:displayable], solr_doc)
    expect(solr_doc).to eq('my_name_ssm' => ['2013-01-10'])
  end

  it "should handle dates that are sortable" do
    Foo.create_and_insert_terms('my_name', Date.parse('2013-01-10'), [:sortable], solr_doc)
    expect(solr_doc).to eq('my_name_dti' => '2013-01-10T00:00:00Z')
  end
end
