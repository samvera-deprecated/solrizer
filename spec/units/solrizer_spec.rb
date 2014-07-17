require 'spec_helper'
require 'time'

describe Solrizer do
  describe ".insert_field" do
    describe "on an empty document" do
      let(:doc) { Hash.new }
      it "should insert a field with the default (stored_searchable) indexer" do
        Solrizer.insert_field(doc, 'foo', 'A name')
        expect(doc).to eq('foo_tesim' => ['A name'])
      end
      it "should not create an array of fields that are not multivalued" do
        Solrizer.insert_field(doc, 'foo', 'A name', :sortable)
        expect(doc).to eq('foo_si' => 'A name')
      end
      it "should insert a field with multiple indexers" do
        Solrizer.insert_field(doc, 'foo', 'A name', :sortable, :facetable)
        expect(doc).to eq('foo_si' => 'A name', 'foo_sim' => ['A name'])
      end
      it "should insert Dates" do
        Solrizer.insert_field(doc, 'foo', Date.parse('2013-01-13'))
        expect(doc).to eq('foo_dtsim' => ["2013-01-13T00:00:00Z"])
      end
      it "should insert Times" do
        Solrizer.insert_field(doc, 'foo', Time.parse('2013-01-13T22:45:56+06:00'))
        expect(doc).to eq('foo_dtsim' => ["2013-01-13T16:45:56Z"])
      end
      it "should insert true Booleans" do
        Solrizer.insert_field(doc, 'foo', true)
        expect(doc).to eq('foo_bsi' => true)
      end
      it "should insert false Booleans" do
        Solrizer.insert_field(doc, 'foo', false)
        expect(doc).to eq('foo_bsi' => false)
      end

      it "should insert multiple values" do
        Solrizer.insert_field(doc, 'foo', ['A name', 'B name'], :sortable, :facetable)
        expect(doc).to eq('foo_si' => 'B name', 'foo_sim' => ['A name', 'B name'])
      end

      it 'should insert nothing when passed a nil value' do
        Solrizer.insert_field(doc, 'foo', nil, :sortable, :facetable)
        expect(doc).to eq( { } )
      end
    end

    describe "on a document with values" do
      let(:doc) { {'foo_si' => 'A name', 'foo_sim' => ['A name']} }

      it "should not overwrite muli-values that exist before" do
        Solrizer.insert_field(doc, 'foo', 'B name', :sortable, :facetable)
        expect(doc).to eq('foo_si' => 'B name', 'foo_sim' => ['A name', 'B name'])
      end
    end
  end
  describe ".set_field" do
    describe "on a document with values" do
      let(:doc) { {'foo_si' => ['A name'], 'foo_sim' => ['A name']} }

      it "should overwrite values that exist before" do
        Solrizer.set_field(doc, 'foo', 'B name', :sortable, :facetable)
        expect(doc).to eq('foo_si' => 'B name', 'foo_sim' => ['B name'])
      end
    end
  end

  describe ".solr_name" do
    it "should delegate to default_field_mapper" do
        expect(Solrizer.solr_name('foo', type: :string)).to eq "foo_tesim"
        expect(Solrizer.solr_name('foo', :sortable)).to eq "foo_si"
    end
  end
end
