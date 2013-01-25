require 'spec_helper'
require 'time'

describe Solrizer do
  describe ".insert_field" do
    describe "on an empty document" do
      let(:doc) { Hash.new }
      it "should insert a field with the default (searchable) indexer" do
        Solrizer.insert_field(doc, 'foo', 'A name')
        doc.should == {'foo_tesim' => ['A name']}
      end
      it "should insert a field with multiple indexers" do
        Solrizer.insert_field(doc, 'foo', 'A name', :sortable, :facetable)
        doc.should == {'foo_ssi' => ['A name'], 'foo_sim' => ['A name']}
      end
      it "should insert Dates" do
        Solrizer.insert_field(doc, 'foo', Date.parse('2013-01-13'))
        doc.should == {'foo_dtsi' => ["2013-01-13T00:00:00Z"]}
      end
      it "should insert Times" do
        Solrizer.insert_field(doc, 'foo', Time.parse('2013-01-13T22:45:56+06:00'))
        doc.should == {'foo_dtsi' => ["2013-01-13T16:45:56Z"]}
      end

      it "should insert multiple values" do
        Solrizer.insert_field(doc, 'foo', ['A name', 'B name'], :sortable, :facetable)
        doc.should == {'foo_ssi' => ['A name', 'B name'], 'foo_sim' => ['A name', 'B name']}
      end
    end

    describe "on a document with values" do
      before{ @doc = {'foo_ssi' => ['A name'], 'foo_sim' => ['A name']}}

      it "should not overwrite values that exist before" do
        Solrizer.insert_field(@doc, 'foo', 'B name', :sortable, :facetable)
        @doc.should == {'foo_ssi' => ['A name', 'B name'], 'foo_sim' => ['A name', 'B name']}
      end
    end
  end
end
