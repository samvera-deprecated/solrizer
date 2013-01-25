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

      # Produces a _s suffix (overrides _tim)
      def self.searchable
        @searchable ||= SearchableDescriptor.new()
      end

      # Produces a _s suffix (overrides _tim)
      def self.another_searchable
        @another_searchable ||= SearchableDescriptor.new()
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
      end

      class SearchableDescriptor < Solrizer::Descriptor
        def name_and_converter(field_name, args)
          [field_name.to_s + '_s']
        end
      end

      class EdibleDescriptor < Solrizer::Descriptor
        def name_and_converter(field_name, args)
          [field_name + '_food']
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
    @mapper.id_field.should == 'ident'
  end


  describe "extract_type" do
    it "should map objects to symbols" do
      @mapper.extract_type(7).should == :integer
      @mapper.extract_type(nil).should == nil
      @mapper.extract_type(Date.today).should == :date
      @mapper.extract_type(Time.now).should == :time
      @mapper.extract_type("Hi").should == :string
    end
  end
  
  describe '.solr_name' do
    it "should map based on index_as" do
      @mapper.solr_name('bar', :edible).should == 'bar_food'
      @mapper.solr_name('bar', :laughable, type: :string).should == 'bar_haha'
    end

    it "should default the index_type to :searchable" do
      @mapper.solr_name('foo').should == 'foo_s'
    end

    it "should map based on data type" do
      @mapper.solr_name('foo', :fungible, type: :integer).should == 'foo_f1'
      @mapper.solr_name('foo', :fungible, type: :garble).should == 'foo_f2'  # based on type.default
      @mapper.solr_name('foo', :fungible, type: :date).should == 'foo_f0'  # type.date falls through to container
    end
  
    it "should return nil for an unknown index types" do
      lambda { 
        @mapper.solr_name('foo', :blargle)
      }.should raise_error(Solrizer::UnknownIndexMacro, "Unable to find `blargle' in [TestMapper0::Descriptors0, Solrizer::DefaultDescriptors]")
    end
    
    it "should allow subclasses to selectively override suffixes" do
      @mapper = TestMapper1.new
      @mapper.solr_name('foo', type: :date).should == 'foo_s'
      @mapper.solr_name('foo', type: :string).should == 'foo_s'
      @mapper.solr_name('foo', :fungible, type: :integer).should == 'foo_f5'  # override on data type
      @mapper.solr_name('foo', :fungible, type: :garble).should == 'foo_f4'  # override on data type
      @mapper.solr_name('foo', :fungible, type: :fratz).should == 'foo_f2'  # from super
      @mapper.solr_name('foo', :fungible, type: :date).should == 'foo_f0'  # super definition picks up override on index type
    end
    
    
    it "should raise an error when field_type is nil" do
      mapper = Solrizer::FieldMapper.new
      lambda { mapper.solr_name(:heifer, nil, :searchable)}.should raise_error Solrizer::InvalidIndexDescriptor
    end
  end
  
  describe '.solr_names_and_values' do
    it "should map values based on index_as" do
      @mapper.solr_names_and_values('foo', 'bar', [:searchable, :laughable, :edible]).should == {
        'foo_s'    => ['bar'],
        'foo_food' => ['bar'],
        'foo_haha' => ["Knock knock. Who's there? Bar. Bar who?"]
      }
    end
    
    it "should apply mappings based on data type" do
      @mapper.solr_names_and_values('foo', 7, [:searchable, :laughable]).should == {
        'foo_s'     => ['7'],
        'foo_ihaha' => ["How many foos does it take to screw in a light bulb? 7."]
      }
    end
    
    it "should raise error on unknown index types" do
      lambda { 
        @mapper.solr_names_and_values('foo', 'bar', [:blargle])
      }.should raise_error(Solrizer::UnknownIndexMacro, "Unable to find `blargle' in [TestMapper0::Descriptors0, Solrizer::DefaultDescriptors]")
    end
    
    it "should generate multiple mappings when two return the _same_ solr name but _different_ values" do
      @mapper.solr_names_and_values('roll', 'rock', [:unstemmed_searchable, :searchable]).should == {
        'roll_s' => ["rock o'clock", 'rock']
      }
    end
    
    it "should not generate multiple mappings when two return the _same_ solr name and the _same_ value" do
      @mapper.solr_names_and_values('roll', 'rock', [:another_searchable, :searchable]).should == {
        'roll_s' => ['rock'],
      }
    end

    it "should return an empty hash when value is nil" do
      @mapper.solr_names_and_values('roll', nil, [:another_searchable, :searchable]).should == { }
    end
  end

  describe Solrizer::FieldMapper do
    before(:each) do
      @mapper = Solrizer::FieldMapper.new
    end
  	
    it "should call the id field 'id'" do
      @mapper.id_field.should == 'id'
    end

    it "should default the index_type to :searchable" do
      @mapper.solr_name('foo', :type=>:string).should == 'foo_tesim'
    end
    
    it "should support field names as symbols" do
      @mapper.solr_name(:active_fedora_model, :symbol).should == "active_fedora_model_ssim"
    end
    
    it "should not apply mappings for searchable by default" do
      # Just sanity check a couple; copy & pasting all data types is silly
      @mapper.solr_names_and_values('foo', 'bar', []).should == {  }
      @mapper.solr_names_and_values('foo', "1",[]).should == { }
    end

    it "should support full ISO 8601 dates" do
      @mapper.solr_names_and_values('foo', "2012-11-06",  [:dateable]).should == { 'foo_dtsi' =>["2012-11-06T00:00:00Z"] }
      @mapper.solr_names_and_values('foo', "November 6th, 2012",  [:dateable]).should == { 'foo_dtsi' =>["2012-11-06T00:00:00Z"] }
      @mapper.solr_names_and_values('foo', "6 Nov. 2012", [:dateable]).should == { 'foo_dtsi' =>["2012-11-06T00:00:00Z"] }
      @mapper.solr_names_and_values('foo', '', [:dateable]).should == { 'foo_dtsi' => [] }
    end

    it "should support displayable, facetable, sortable, unstemmed" do
      @mapper.solr_names_and_values('foo', 'bar', [:searchable, :displayable, :facetable, :sortable, :unstemmed_searchable]).should == {
        "foo_tesim" => ["bar"], #searchable
        "foo_sim" => ["bar"], #facetable
        "foo_ssm" => ["bar"], #displayable
        "foo_ssi" => ["bar"], #sortable
        "foo_tim" => ["bar"] #unstemmed_searchable
      }
    end
  end
end
