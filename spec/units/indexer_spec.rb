require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'indexer'

describe Indexer do
    
  # before(:each) do
  #   Indexer.any_instance.stubs(:connect).returns("foo")
  #   @indexer = Indexer.new
  # end
  
  describe "#solrize" do
    it "should convert a hash to a solr doc" do
      example_hash = {"box"=>"Box 51A", "city"=>["Ann Arbor", "Hyderabad", "Palo Alto"], "person"=>["ELLIE ENGELMORE", "Reddy", "EDWARD FEIGENBAUM"], "title"=>"Letter from Ellie Engelmore to Professor K. C. Reddy", "series"=>"eaf7000", "folder"=>"Folder 15", "technology"=>["artificial intelligence"], "year"=>"1985", "organization"=>["Heuristic Programming Project", "Mathematics and Computer/Information Sciences University of Hyderabad Central University P. O. Hyder", "Professor K. C. Reddy School of Mathematics and Computer/Information Sciences"], "collection"=>"e-a-feigenbaum-collection", "state"=>["Michigan", "California"]}
      
      example_result = Indexer.solrize( example_hash )
      example_result.should be_kind_of Solr::Document
      example_hash.each_pair do |key,values|
        if values.class == String
          example_result["#{key}_facet"].should == values
        else
          values.each do |v|
            example_result.inspect.include?"@name=\"#{key}_facet\", @boost=nil, @value=\"#{v}\"".should be_true 
          end
        end        
      end
    end
    
    it "should handle hashes with facets listed in a sub-hash" do
      simple_hash = Hash[:facets => {'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]}]
      result = Indexer.solrize( simple_hash )
      result.should be_kind_of Solr::Document
      result["technology_facet"].should == "t1"
      result.inspect.include?'@name="technology_facet", @boost=nil, @value="t2"'.should be_true
      result["company_facet"].should == "c1"
      result["person_facet"].should == "p1"
      result.inspect.include?'@name="person_facet", @boost=nil, @value="p2"'.should be_true
    end
  end
end
