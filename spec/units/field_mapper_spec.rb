require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Solrizer::FieldMapper do
  
  before(:each) do
    @mapper = TestMapper0.new
  end
  
  after(:all) do
  end
  
  class TestMapper0 < Solrizer::FieldMapper
    id_field 'ident'
    index_as :searchable, :suffix => '_s',    :default => true
    index_as :edible,     :suffix => '_food'
    index_as :laughable,  :suffix => '_haha', :default => true do |type|
      type.integer :suffix => '_ihaha' do |value, field_name|
        "How many #{field_name}s does it take to screw in a light bulb? #{value}."
      end
      type.default do |value|
        "Knock knock. Who's there? #{value.capitalize}. #{value.capitalize} who?"
      end
    end
    index_as :fungible, :suffix => '_f0' do |type|
      type.integer :suffix => '_f1'
      type.date
      type.default :suffix => '_f2'
    end
  end
  
  class TestMapper1 < TestMapper0
    index_as :searchable do |type|
      type.date :suffix => '_d'
    end
    index_as :fungible, :suffix => '_f3' do |type|
      type.garble  :suffix => '_f4'
      type.integer :suffix => '_f5'
    end
  end
  
  describe 'solr_name' do
  
    it "should map based on index_as" do
      @mapper.solr_name('bar', :string, :edible).should == 'bar_food'
      @mapper.solr_name('bar', :string, :laughable).should == 'bar_haha'
    end

    it "should default the index_type to :searchable" do
      @mapper.solr_name('foo', :string).should == 'foo_s'
    end
    
    it "should map based on data type" do
      @mapper.solr_name('foo', :integer, :fungible).should == 'foo_f1'
      @mapper.solr_name('foo', :garble,  :fungible).should == 'foo_f2'  # based on type.default
      @mapper.solr_name('foo', :date,    :fungible).should == 'foo_f0'  # type.date falls through to container
    end
  
    it "should return nil for an unknown mapping" do
      @mapper.solr_name('foo', :string, :blargle).should == nil
    end
    
    it "should allow subclasses to selectively override suffixes" do
      @mapper = TestMapper1.new
      @mapper.solr_name('foo', :date).should == 'foo_d'   # override
      @mapper.solr_name('foo', :string).should == 'foo_s' # from super
      @mapper.solr_name('foo', :integer, :fungible).should == 'foo_f5'  # override on data type
      @mapper.solr_name('foo', :garble,  :fungible).should == 'foo_f4'  # override on data type
      @mapper.solr_name('foo', :fratz,   :fungible).should == 'foo_f2'  # from super
      @mapper.solr_name('foo', :date,    :fungible).should == 'foo_f3'  # super definition picks up override on index type
    end
    
  end
  
  describe 'solr_names_and_values' do
    # it "should map values based on index_as" do
    #   @mapper.solr_names_and_values('foo', 'bar', :string, [:searchable, :laughable]).should == {
    #     'foo_s' => 'bar',
    #     'foo_food' => 'bar',
    #     'foo_haha' => "Knock knock. Who's there? Foo. Foo who?"
    #   }
    # end
    # 
    # it "should apply default index_as mapping unless excluded with not_" do
    #   @mapper.solr_names_and_values('foo', 'bar', :string, []).should == {
    #     'foo_s' => 'bar',
    #     'foo_haha' => "Knock knock. Who's there? Foo. Foo who?"
    #   }
    #   @mapper.solr_names_and_values('foo', 'bar', :string, [:edible, :not_laughable]).should == {
    #     'foo_s' => 'bar',
    #     'foo_food' => 'bar'
    #   }
    # end
  
    it "should apply mappings based on data type"
    it "should generate multiple mappings when two return the _same_ solr name but _different_ values"
    it "should not generate multiple mappings when two return the _same_ solr name and the _same_ value"
  end
  
  it "should parse the id field"
  
  describe 'DefaultMapper' do
    it "should called the id field 'id'"
    it "should apply mappings for searchable by default"
    it "should support displayable, facetable, sortable, unstemmed"
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
