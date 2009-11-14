require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'extractor'

describe Extractor do
  before(:all) do
    @descriptor = Descriptor.register("sc0340")
  end
  
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
  
  # describe ".extractFacetCategories" do
  #   it "should extract facet info from extracted entities" do
  #     extracted_meta = fixture("druid-bv448hq0314-extProperties.xml") 
  #     result = @extractor.extractFacetCategories( extracted_meta )
  #     result.should == {"box"=>"Box 51A", "city"=>"Palo Alto", "person"=>"EDWARD FEIGENBAUM", "title"=>"Letter from Ellie Engelmore to Professor K. C. Reddy", "series"=>"eaf7000", "folder"=>"Folder 15", "technology"=>"artificial intelligence", "year"=>"1985", "organization"=>"Professor K. C. Reddy School of Mathematics and Computer/Information Sciences", "collection"=>"e-a-feigenbaum-collection", "state"=>"California"}
  #   end
  # end
  
  # The hash output of this method will be merged into the facets hash in extract_facet_categories
  describe "extract_location_info" do
    it "should extract series, box, & folder and add collection/series and subseries info to boot" do
      ext_properties = fixture("druid-cm234kq4672-extProperties.xml") 
      result = @extractor.extract_location_info( ext_properties )
      result.should == {:facets=>{"series"=>"Accession 2005-101>", "subseries"=> "Stanford Materials", "box"=>"Box 51", "folder"=>"5: EAF Printed CorrespondenceApril-Sept. 1984", "collection"=>"Edward A. Feigenbaum Papers"}, :symbols=>{"box"=>"Box 51", "folder"=>"Folder 5", "series"=>"eaf7000"}}
    end
    it "should fail gracefully when there is no EAD info for the document's location info" do
      ext_properties = fixture("druid-bv448hq0314-extProperties.xml") 
      result = @extractor.extract_location_info( ext_properties )
      result.should == {:facets=>{'box' => 'Box 51A', 'folder' => '15: Folder 15', 'series' => 'Accession 2005-101>', 'collection' => "Edward A. Feigenbaum Papers"}, :symbols=>{'box' => 'Box 51A', 'folder' => 'Folder 15', 'series' => 'eaf7000'}}
    end
  end
  
  describe "extract_facets" do
    it "should extract facet info to a hash" do
      ext_properties = fixture("druid-bv448hq0314-extProperties.xml") 
      # doc = REXML::Document.new( ext_properties )
      result = @extractor.extract_facets( ext_properties )   
      result.should == {"city"=>["Ann Arbor", "Hyderabad", "Palo Alto"], "person"=>["ELLIE ENGELMORE", "Reddy", "EDWARD FEIGENBAUM"], "title"=>"Letter from Ellie Engelmore to Professor K. C. Reddy", "technology"=>["artificial intelligence"], "year"=>"1985", "organization"=>["Heuristic Programming Project", "Mathematics and Computer/Information Sciences University of Hyderabad Central University P. O. Hyder", "Professor K. C. Reddy School of Mathematics and Computer/Information Sciences"], "state"=>["Michigan", "California"]}
    end
  end
  
  describe "extract_ext_properties" do
    it "should extract facet info to a hash" do
      ext_properties = fixture("druid-bv448hq0314-extProperties.xml") 
      # doc = REXML::Document.new( ext_properties )
      result = @extractor.extract_ext_properties( ext_properties )   
      result.should == {:facets=>{'box' => 'Box 51A', 'folder' => '15: Folder 15','series' => 'Accession 2005-101>', 'collection' => "Edward A. Feigenbaum Papers", "city"=>["Ann Arbor", "Hyderabad", "Palo Alto"], "person"=>["ELLIE ENGELMORE", "Reddy", "EDWARD FEIGENBAUM"], "title"=>"Letter from Ellie Engelmore to Professor K. C. Reddy", "technology"=>["artificial intelligence"], "year"=>"1985", "organization"=>["Heuristic Programming Project", "Mathematics and Computer/Information Sciences University of Hyderabad Central University P. O. Hyder", "Professor K. C. Reddy School of Mathematics and Computer/Information Sciences"], "state"=>["Michigan", "California"]}, :symbols=>{'box' => 'Box 51A', 'folder' => 'Folder 15', 'series' => 'eaf7000'}}
    end
  end
  
  describe "#ead_folder_title" do
      it "should return the title for the given series, box and folder, appending folder number to the title" do
        @extractor.ead_folder_title("Accession 1986-052>", "Box 51", "Folder 12", @descriptor).should == "12: Pylyshyn, Zenon W."
      end
      it "should work with eaf7000 as series name" do
        @extractor.ead_folder_title("eaf7000", "Box 20", "Folder 57", @descriptor).should == "57: SRI Papers of W. F. Miller"
      end
      it "should work with box and folder numbers" do
        @extractor.ead_folder_title("Accession 2005-101>", "74", "11", @descriptor).should == "11: Feigenbaum, MacNeil -Lehrer Report, \"Artificial Intelligence\"1987"
        @extractor.ead_folder_title("Accession 2005-101>", 46, 7, @descriptor).should == "7: \"Human Processing of Knowledge from Texts: Acquisition, Integration, and Reasoning\" by P.W. Thorndyke and B. Hayes-Roth1979"
      end
      it "should work with folders that include the folder id and title already" do
        @extractor.ead_folder_title("Accession 2005-101>", "74", "11: Feigenbaum, MacNeil -Lehrer Report, \"Artificial Intelligence\" 1987", @descriptor).should == "11: Feigenbaum, MacNeil -Lehrer Report, \"Artificial Intelligence\" 1987"
      end
    end
  
end