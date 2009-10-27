require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'extractor'

describe Extractor do
  before(:each) do
    @extractor = Extractor.new
  end
  
  describe ".xml_to_solr" do
    it "should turn simple xml into a solr document" do
      desc_meta = fixture("druid-bv448hq0314-descMetadata.xml")
      result = @extractor.xml_to_solr(desc_meta)
      result[:type_t].should == "text"
      result[:medium_t].should == "Paper Document"
      result[:rights_t].should == "Presumed under copyright. Do not publish."
      result[:date_t].should == "1985-12-30"
      result[:format_t].should == "application/tiff"
      result[:title_t].should == "This is a Sample Title"
      result[:publisher_t].should == "Sample Unversity"
      # ... and a hacky way of making sure that it added a field for each of the dc:medium values
      result.inspect.include?'@name="format_t", @boost=nil, @value="application/tiff"'.should be_true
      result.inspect.include?'@name="format_t", @boost=nil, @value="application/pdf"'.should be_true
    end
  end
  
  describe ".extractFacetCategories" do
    it "should extract facet info from extracted entities" do
      extracted_meta = fixture("druid-bv448hq0314-extProperties.xml") 
      result = @extractor.extractFacetCategories( extracted_meta )
      result.should == {"box"=>"Box 51A", "city"=>"Palo Alto", "person"=>"EDWARD FEIGENBAUM", "title"=>"Letter from Ellie Engelmore to Professor K. C. Reddy", "series"=>"eaf7000", "folder"=>"Folder 15", "technology"=>"artificial intelligence", "year"=>"1985", "organization"=>"Professor K. C. Reddy School of Mathematics and Computer/Information Sciences", "collection"=>"e-a-feigenbaum-collection", "state"=>"California"}
    end
  end
  
  # The hash output of this method will be merged into the facets hash in extract_facet_categories
  describe "extract_location_info" do
    it "should extract series, box, & folder and add collection info to boot" do
      extracted_meta = fixture("druid-bv448hq0314-extProperties.xml") 
      doc = REXML::Document.new( extracted_meta )
      result = @extractor.extract_location_info( doc )
      result.should == Hash['box' => 'Box 51A', 'folder' => 'Folder 15', 'series' => 'eaf7000', 'collection' => 'e-a-feigenbaum-collection']
    end
  end
end