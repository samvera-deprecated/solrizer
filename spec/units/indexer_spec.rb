require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'shelver'

describe Shelver::Indexer do
    
  before(:each) do
     Shelver::Indexer.any_instance.stubs(:connect).returns("foo")
  
     @extractor = mock("Extractor")
     @extractor.stubs(:html_content_to_solr).returns(@solr_doc)
#     @solr_doc = mock('solr_doc')
#     @solr_doc.stubs(:<<)
#     @solr_doc.stubs(:[])
     
     @solr_doc = Solr::Document.new
     
     Shelver::Extractor.expects(:new).returns(@extractor)
     @indexer = Shelver::Indexer.new
     
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
  
  
  
  describe "#solrize" do
    it "should convert a hash to a solr doc" do
      example_hash = {"box"=>"Box 51A", "city"=>["Ann Arbor", "Hyderabad", "Palo Alto"], "person"=>["ELLIE ENGELMORE", "Reddy", "EDWARD FEIGENBAUM"], "title"=>"Letter from Ellie Engelmore to Professor K. C. Reddy", "series"=>"eaf7000", "folder"=>"Folder 15", "technology"=>["artificial intelligence"], "year"=>"1985", "organization"=>["Heuristic Programming Project", "Mathematics and Computer/Information Sciences University of Hyderabad Central University P. O. Hyder", "Professor K. C. Reddy School of Mathematics and Computer/Information Sciences"], "collection"=>"e-a-feigenbaum-collection", "state"=>["Michigan", "California"]}
      
      example_result = Shelver::Indexer.solrize( example_hash )
      example_result.should be_kind_of Solr::Document
      example_hash.each_pair do |key,values|
        if values.class == String
          example_result["#{key}_facet"].should == values
        else
          values.each do |v|
            example_result.inspect.include?("@name=\"#{key}_facet\"").should be_true
            example_result.inspect.include?("@value=\"#{v}\"").should be_true
          end
        end        
      end
    end
    
    it "should handle hashes with facets listed in a sub-hash" do
      simple_hash = Hash[:facets => {'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]}]
      result = Shelver::Indexer.solrize( simple_hash )
      result.should be_kind_of Solr::Document
      result["technology_facet"].should == "t1"
      result.inspect.include?('@boost=nil').should be_true
      result.inspect.include?('@name="technology_facet"').should be_true
      result.inspect.include?('@value="t2"').should be_true
      result["company_facet"].should == "c1"
      result["person_facet"].should == "p1"
      result.inspect.include?('@name="person_facet"').should be_true
      result.inspect.include?('@value="p2"').should be_true
      
    end
    
    it "should create symbols from the :symbols subhash" do
      simple_hash = Hash[:facets => {'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]}, :symbols=>{'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]}]
      result = Shelver::Indexer.solrize( simple_hash )
      result.should be_kind_of Solr::Document
      result["technology_s"].should == "t1"
      result.inspect.include?('@name="technology_s"').should be_true
      result.inspect.include?('@value="t2"').should be_true
    
      result["company_s"].should == "c1"
      result["person_s"].should == "p1"
      result.inspect.include?('@name="person_s"').should be_true
      result.inspect.include?('@value="p2"').should be_true
  
    end
  end
end
