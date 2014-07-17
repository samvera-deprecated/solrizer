require 'spec_helper'

describe Solrizer::FieldMapper do
  
  # --- Test Mappings ----
  class TestMapper0 < Solrizer::FieldMapper
    self.id_field= 'ident'
    module Descriptors0
      # Produces a _s suffix (overrides _tim)
      def self.unstemmed_searchable
        @unstemmed_searchable ||= UnstemmedDescriptor.new()
      end

      # Produces a _s suffix (overrides _tesim)
      def self.stored_searchable
        @searchable ||= StoredSearchableDescriptor.new()
      end

      # Produces a _s suffix (overrides _tesim)
      def self.another_stored_searchable
        @another_searchable ||= StoredSearchableDescriptor.new()
      end

      def self.edible
        @edible ||= EdibleDescriptor.new()
      end

      def self.fungible
        @fungible ||= FungibleDescriptor.new()
      end

      def self.laughable
        @laughable ||= LaughableDescriptor.new()
      end

      class UnstemmedDescriptor < Solrizer::Descriptor
        def name_and_converter(field_name, args)
          [field_name + '_s', lambda { |value| "#{value} o'clock" }]
        end
        def index_type
          [:multivalued]
        end
      end

      class StoredSearchableDescriptor < Solrizer::Descriptor
        def name_and_converter(field_name, args)
          [field_name.to_s + '_s']
        end
        def index_type
          [:multivalued]
        end
      end

      class EdibleDescriptor < Solrizer::Descriptor
        def name_and_converter(field_name, args)
          [field_name + '_food']
        end
        def index_type
          [:multivalued]
        end
      end

      class FungibleDescriptor < Solrizer::Descriptor
        def name_and_converter(field_name, args)
          [field_name + fungible_type(args[:type])]
        end
        def fungible_type(type)
          case type
          when :integer
            '_f1'
          when :date
            '_f0'
          else
            '_f2'
          end
        end
      end

      class LaughableDescriptor < Solrizer::Descriptor
        def name_and_converter(field_name, args)
          field_type = args[:type]
          [field_name + laughable_type(field_type), laughable_converter(field_type)]
        end

        def laughable_type(type)
          case type
          when :integer
            '_ihaha'
          else
            '_haha'
          end
        end

        def laughable_converter(type)
          case type
          when :integer
            lambda do |value, field_name| 
              "How many #{field_name}s does it take to screw in a light bulb? #{value}."
            end
          else
            lambda do |value| 
              "Knock knock. Who's there? #{value.capitalize}. #{value.capitalize} who?"
            end
          end
        end
        def index_type
          [:multivalued]
        end
      end
    end

    self.descriptors = [Descriptors0, Solrizer::DefaultDescriptors]
  end
  
  class TestMapper1 < TestMapper0
    module Descriptors1
      def self.fungible
        @fungible ||= FungibleDescriptor.new()
      end

      class FungibleDescriptor < TestMapper0::Descriptors0::FungibleDescriptor
        def name_and_converter(field_name, args)
          [field_name + fungible_type(args[:type])]
        end

        def fungible_type(type)
            case type
            when :garble
              '_f4'
            when :integer
              '_f5'
            else
              super
            end
        end
      end
    end
    self.descriptors = [Descriptors1, Descriptors0, Solrizer::DefaultDescriptors]
  end
  
  before(:each) do
    @mapper = TestMapper0.new
  end
  
  after(:all) do
  end
  
  # --- Tests ----
  
  it "should handle the id field" do
    expect(@mapper.id_field).to eq 'ident'
  end


  describe "extract_type" do
    it "should map objects to symbols" do
      expect(@mapper.extract_type(7)).to eq :integer
      expect(@mapper.extract_type(nil)).to eq nil
      expect(@mapper.extract_type(Date.today)).to eq :date
      expect(@mapper.extract_type(Time.now)).to eq :time
      expect(@mapper.extract_type(DateTime.now)).to eq :time
      expect(@mapper.extract_type("Hi")).to eq :string
    end
  end
  
  describe '.solr_name' do
    it "should map based on passed descriptors" do
      expect(@mapper.solr_name('bar', :edible)).to eq 'bar_food'
      expect(@mapper.solr_name('bar', :laughable, type: :string)).to eq 'bar_haha'
    end

    it "should default the index_type to :stored_searchable" do
      expect(@mapper.solr_name('foo')).to eq 'foo_s'
    end

    it "should allow you to pass a string as the suffix" do
      expect(@mapper.solr_name('bar', 'quack')).to eq 'bar_quack'
    end

    it "should map based on data type" do
      expect(@mapper.solr_name('foo', :fungible, type: :integer)).to eq 'foo_f1'
      expect(@mapper.solr_name('foo', :fungible, type: :garble)).to eq 'foo_f2'  # based on type.default
      expect(@mapper.solr_name('foo', :fungible, type: :date)).to eq 'foo_f0'  # type.date falls through to container
    end
  
    it "should return nil for an unknown index types" do
      expect { 
        @mapper.solr_name('foo', :blargle)
      }.to raise_error(Solrizer::UnknownIndexMacro, "Unable to find `blargle' in [TestMapper0::Descriptors0, Solrizer::DefaultDescriptors]")
    end
    
    it "should allow subclasses to selectively override suffixes" do
      @mapper = TestMapper1.new
      expect(@mapper.solr_name('foo', type: :date)).to eq 'foo_s'
      expect(@mapper.solr_name('foo', type: :string)).to eq 'foo_s'
      expect(@mapper.solr_name('foo', :fungible, type: :integer)).to eq 'foo_f5'  # override on data type
      expect(@mapper.solr_name('foo', :fungible, type: :garble)).to eq 'foo_f4'  # override on data type
      expect(@mapper.solr_name('foo', :fungible, type: :fratz)).to eq 'foo_f2'  # from super
      expect(@mapper.solr_name('foo', :fungible, type: :date)).to eq 'foo_f0'  # super definition picks up override on index type
    end
    
    
    it "should raise an error when field_type is nil" do
      mapper = Solrizer::FieldMapper.new
      expect { mapper.solr_name(:heifer, nil, :searchable) }.to raise_error Solrizer::InvalidIndexDescriptor
    end
  end
  
  describe '.solr_names_and_values' do
    it "should map values based on passed descriptors" do
      expect(@mapper.solr_names_and_values('foo', 'bar', [:stored_searchable, :laughable, :edible])).to eq(
        'foo_s'    => ['bar'],
        'foo_food' => ['bar'],
        'foo_haha' => ["Knock knock. Who's there? Bar. Bar who?"]
      )
    end
    
    it "should apply mappings based on data type" do
      expect(@mapper.solr_names_and_values('foo', 7, [:stored_searchable, :laughable])).to eq(
        'foo_s'     => ['7'],
        'foo_ihaha' => ["How many foos does it take to screw in a light bulb? 7."]
      )
    end
    
    it "should raise error on unknown index types" do
      expect { 
        @mapper.solr_names_and_values('foo', 'bar', [:blargle])
      }.to raise_error(Solrizer::UnknownIndexMacro, "Unable to find `blargle' in [TestMapper0::Descriptors0, Solrizer::DefaultDescriptors]")
    end
    
    it "should generate multiple mappings when two return the _same_ solr name but _different_ values" do
      expect(@mapper.solr_names_and_values('roll', 'rock', [:unstemmed_searchable, :stored_searchable])).to eq(
        'roll_s' => ["rock o'clock", 'rock']
      )
    end
    
    it "should not generate multiple mappings when two return the _same_ solr name and the _same_ value" do
      expect(@mapper.solr_names_and_values('roll', 'rock', [:another_stored_searchable, :stored_searchable])).to eq(
        'roll_s' => ['rock'],
      )
    end

    it "should return an empty hash when value is nil" do
      expect(@mapper.solr_names_and_values('roll', nil, [:another_stored_searchable, :stored_searchable])).to eq({ })
    end
  end

  describe Solrizer::FieldMapper do
    before(:each) do
      @mapper = Solrizer::FieldMapper.new
    end
  	
    it "should call the id field 'id'" do
      expect(@mapper.id_field).to eq 'id'
    end

    it "should default the index_type to :stored_searchable" do
      expect(@mapper.solr_name('foo', :type=>:string)).to eq 'foo_tesim'
    end
    
    it "should support field names as symbols" do
      expect(@mapper.solr_name(:active_fedora_model, :symbol)).to eq "active_fedora_model_ssim"
    end
    
    it "should not apply mappings for searchable by default" do
      # Just sanity check a couple; copy & pasting all data types is silly
      expect(@mapper.solr_names_and_values('foo', 'bar', [])).to eq({  })
      expect(@mapper.solr_names_and_values('foo', "1",[])).to eq({ })
    end

    it "should support full ISO 8601 dates" do
      expect(@mapper.solr_names_and_values('foo', "2012-11-06",  [:dateable])).to eq('foo_dtsim' =>["2012-11-06T00:00:00Z"])
      expect(@mapper.solr_names_and_values('foo', "November 6th, 2012",  [:dateable])).to eq('foo_dtsim' =>["2012-11-06T00:00:00Z"])
      expect(@mapper.solr_names_and_values('foo', "6 Nov. 2012", [:dateable])).to eq('foo_dtsim' =>["2012-11-06T00:00:00Z"])
      expect(@mapper.solr_names_and_values('foo', '', [:dateable])).to eq('foo_dtsim' => [])
    end

    it "should support searchable, stored_searchable, displayable, facetable, sortable, stored_sortable, unstemmed" do
      descriptors = [:searchable, :stored_searchable, :displayable, :facetable, :sortable, :stored_sortable, :unstemmed_searchable]
      expect(@mapper.solr_names_and_values('foo', 'bar', descriptors)).to eq(
        "foo_teim" => ["bar"], #searchable
        "foo_tesim" => ["bar"], #stored_searchable
        "foo_ssm" => ["bar"], #displayable
        "foo_sim" => ["bar"], #facetable
        "foo_si" => "bar", #sortable
        "foo_ssi" => "bar", #stored_sortable
        "foo_tim" => ["bar"] #unstemmed_searchable
      )
    end

    it "should support stored_sortable" do
      time = Time.iso8601("2012-11-06T15:16:17Z")
      expect(@mapper.solr_names_and_values('foo', time, :stored_sortable)).to eq("foo_dtsi" => "2012-11-06T15:16:17Z")
      expect(@mapper.solr_names_and_values('foo', 'bar', :stored_sortable)).to eq("foo_ssi" => "bar")
    end
  end
end
