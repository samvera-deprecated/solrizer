require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'solrizer'
require "solrizer/fedora"

describe Solrizer::Fedora::Indexer do
    
  before(:each) do
     Solrizer::Fedora::Indexer.any_instance.stubs(:connect).returns("foo")
  
     @extractor = mock("Extractor")
     @extractor.stubs(:html_content_to_solr).returns(@solr_doc)
#     @solr_doc = mock('solr_doc')
#     @solr_doc.stubs(:<<)
#     @solr_doc.stubs(:[])
     
     @solr_doc = Solr::Document.new
     
     Solrizer::Extractor.expects(:new).returns(@extractor)
     @indexer = Solrizer::Fedora::Indexer.new
     
   end
  
  describe "#generate_dates" do
    it "should still give 9999-99-99 date if the solr document does not have a date_t field" do
    
    solr_result = @indexer.generate_dates(@solr_doc)
    solr_result.should be_kind_of Solr::Document
    solr_result[:date_t].should == "9999-99-99"
    solr_result[:month_facet].should == "99"
    solr_result[:day_facet].should == '99'
    
    end
    
    it "should still give 9999-99-99 date if the solr_doc[:date_t] is not valid date in YYYY-MM-DD format " do
     
      @solr_doc << Solr::Field.new(:date_t => "Unknown")
      solr_result = @indexer.generate_dates(@solr_doc)
      solr_result.should be_kind_of Solr::Document
      solr_result[:date_t].should == "Unknown"
      solr_result[:month_facet].should == "99"
      solr_result[:day_facet].should == '99'
  
    end
    
    it "should give month and dates even if the :date_t is not a valid date but is in YYYY-MM-DD format  " do
      
       @solr_doc << Solr::Field.new(:date_t => "0000-13-11")
       solr_result = @indexer.generate_dates(@solr_doc)
       solr_result.should be_kind_of Solr::Document
       solr_result[:date_t].should == "0000-13-11"
       solr_result[:month_facet].should == "99"
       solr_result[:day_facet].should == '11'
     end
     
     it "should give month and day when in a valid date format" do
           @solr_doc << Solr::Field.new(:date_t => "1978-04-11")
            solr_result = @indexer.generate_dates(@solr_doc)
            solr_result.should be_kind_of Solr::Document
            solr_result[:date_t].should == "1978-04-11"
            solr_result[:month_facet].should == "04"
            solr_result[:day_facet].should == '11'
     
     end
     
     it "should still give two digit strings even if the month/day is single digit" do
     
         @solr_doc << Solr::Field.new(:date_t => "1978-4-1")
         solr_result = @indexer.generate_dates(@solr_doc)
         solr_result.should be_kind_of Solr::Document
         solr_result[:date_t].should == "1978-4-1"
         solr_result[:month_facet].should == "04"
         solr_result[:day_facet].should == '01'  
     
     end
     
  end

end
