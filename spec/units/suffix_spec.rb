require 'spec_helper'

describe Solrizer::Suffix do

  describe "#multivalued?" do
    it "should be multivalued if :multivalued is among the field types" do
      expect(Solrizer::Suffix.new(:multivalued)).to be_multivalued
    end

    it "should not be multivalued if :multivalued was not passed in a field type" do
      expect(Solrizer::Suffix.new(:some_other_field_type)).to_not be_multivalued
    end
  end

  describe "#stored?" do
    it "should be stored if :stored is among the field types" do
      expect(Solrizer::Suffix.new(:stored)).to be_stored
    end

    it "should not be stored if :stored was not passed in a field type" do
      expect(Solrizer::Suffix.new(:some_other_field_type)).to_not be_stored
    end
  end

  describe "#indexed?" do
    it "should be indexed if :indexed is among the field types" do
      expect(Solrizer::Suffix.new(:indexed)).to be_indexed
    end

    it "should not be indexed if :indexed was not passed in a field type" do
      expect(Solrizer::Suffix.new(:some_other_field_type)).to_not be_indexed
    end
  end
  describe "#has_field?" do  
    subject do
      Solrizer::Suffix.new(:type, :a, :b, :c)
    end  
    it "should be able to tell if a field is in the suffix or not" do
      expect(subject).to have_field :a
      expect(subject).to have_field :b
      expect(subject).to have_field :c
      expect(subject).to_not have_field :d
    end
  end

  describe "#data_type" do
    it "should always be the first argument to the suffix" do
      expect(Solrizer::Suffix.new(:some_type, :a).data_type).to eq :some_type
    end
  end

  describe "#to_s" do
    it "should combine the fields into a suffix string" do
      expect(Solrizer::Suffix.new(:string, :stored, :indexed).to_s).to eq '_ssi'
      expect(Solrizer::Suffix.new(:integer, :stored, :multivalued).to_s).to eq '_ism'
    end
    it "should be able to handle longs" do
      expect(Solrizer::Suffix.new(:long, :stored, :indexed).to_s).to eq '_ltsi'
    end
  end

  describe "config" do
    subject do
      Solrizer::Suffix.new(:my_custom_type, :a, :b, :c)
    end  

    it "should let you mess with the suffix config" do
      subject.config.fields += [:b]
      subject.config.suffix_delimiter = "#"
      subject.config.type_suffix = lambda do |fields|
        type = fields.first

        if type == :my_custom_type
          "custom_suffix_"
        else
          "nope"
        end
      end
      subject.config.b_suffix = 'now_with_more_b'
      expect(subject.to_s).to eq "#custom_suffix_now_with_more_b"
    end
  end
end
