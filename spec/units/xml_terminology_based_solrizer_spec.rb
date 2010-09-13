require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'solrizer'
require 'solrizer/xml'

describe Solrizer::XML::TerminologyBasedSolrizer do
  
  before(:all) do
    OM::Samples::ModsArticle.send(:include, Solrizer::XML::TerminologyBasedSolrizer)
  end
  
  before(:each) do
    article_xml = fixture( File.join("mods_articles", "hydrangea_article1.xml") )
    @mods_article = OM::Samples::ModsArticle.from_xml(article_xml)
  end
  
  describe ".to_solr" do
  
    # after(:all) do
    #   # Revert to default mappings after running tests
    #   ActiveFedora::SolrService.load_mappings
    # end
  
    it "should provide .to_solr and return a SolrDocument" do
      @mods_article.should respond_to(:to_solr)
      @mods_article.to_solr.should be_kind_of(Solr::Document)
    end
  
    it "should optionally allow you to provide the Solr::Document to add fields to and return that document when done" do
      doc = Solr::Document.new
      @mods_article.to_solr(doc).should equal(doc)
    end
  
    it "should iterate through the terminology terms, calling .solrize_term on each and passing in the solr doc" do
      # mock_terms = {:name1=>:term1, :name2=>:term2}
      # ActiveFedora::NokogiriDatastream.stubs(:accessors).returns(mock_accessors)
      solr_doc = Solr::Document.new
      OM::Samples::ModsArticle.terminology.terms.each_pair do |k,v|
        @mods_article.expects(:solrize_term).with(v, solr_doc)
      end
      @mods_article.to_solr(solr_doc)
    end
  
    it "should use Solr mappings to generate field names" do

      solr_doc =  @mods_article.to_solr
      #should have these
      
      solr_doc[:abstract].should be_nil
      solr_doc[:abstract_t].should == "ABSTRACT"
      solr_doc[:title_info_1_language_t].should == "finnish"
      solr_doc[:person_1_role_0_text_t].should == "teacher"

      # These are a holdover from an old verison of OM
      # solr_doc[:finnish_title_info_language_t].should == "finnish"
      # solr_doc[:finnish_title_info_main_title_t].should == "Artikkelin otsikko Hydrangea artiklan 1"

      # solr_doc[:mydate_date].should == "fake-date"
      # 
      # solr_doc[:publisher_t].should be_nil
      # solr_doc[:coverage_t].should be_nil
      # solr_doc[:creation_date_dt].should be_nil
      # solr_doc.should == ""
    
    end
  
  end

  describe ".solrize_term" do
  
    it "should add fields to a solr document for all nodes corresponding to the given term and its children" do
      solr_doc = Solr::Document.new
      result = @mods_article.solrize_term(OM::Samples::ModsArticle.terminology.retrieve_term(:title_info), solr_doc)
      result.should == solr_doc
      # @mods_article.solrize_term(:title_info, OM::Samples::ModsArticle.terminology.retrieve_term(:title_info), :solr_doc=>solr_doc).should == ""
    end
  
  end

  describe ".solrize_node" do
    it "should optionally allow you to provide the Solr::Document to add fields to and return that document when done" do
      doc = Solr::Document.new
      # @mods_article.solrize_node(node, term_pointer, term, solr_doc).should equal(doc)
    end
    it "should create a solr field containing node.text"
    it "should create hierarchical field entries if parents is not empty"
    it "should only create one node if parents is empty"
  end
end