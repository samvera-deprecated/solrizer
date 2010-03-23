require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/shelver/extractor'

describe Shelver::Extractor do
  
  before(:each) do
    @extractor = Shelver::Extractor.new
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
      result.inspect.include?('@value="application/tiff"').should be_true
      result.inspect.include?('@value="application/pdf"').should be_true
    end
  end
  
  # describe ".extractFacetCategories" do
  #   it "should extract facet info from extracted entities" do
  #     extracted_meta = fixture("druid-bv448hq0314-extProperties.xml") 
  #     result = @extractor.extractFacetCategories( extracted_meta )
  #     result.should == {"box"=>"Box 51A", "city"=>"Palo Alto", "person"=>"EDWARD FEIGENBAUM", "title"=>"Letter from Ellie Engelmore to Professor K. C. Reddy", "series"=>"eaf7000", "folder"=>"Folder 15", "technology"=>"artificial intelligence", "year"=>"1985", "organization"=>"Professor K. C. Reddy School of Mathematics and Computer/Information Sciences", "collection"=>"e-a-feigenbaum-collection", "state"=>"California"}
  #   end
  # end
  
  describe "extract_rels_ext" do 
    it "should extract the content model of the RELS-EXT datastream of a Fedora object and set hydra_type using hydra_types mapping" do
      rels_ext = fixture("rels_ext_cmodel.xml")
      result = @extractor.extract_rels_ext( rels_ext )
      result[:cmodel_t].should == "info:fedora/fedora-system:ContentModel-3.0"
      result[:hydra_type_t].should == "salt_document"
      
      # ... and a hacky way of making sure that it added a field for each of the dc:medium values
      result.inspect.include?('@value="info:fedora/afmodel:SaltDocument"').should be_true
      result.inspect.include?('@value="jp2_document"').should be_true
    end
  end
  
  describe "extract_hydra_types" do 
    it "should extract the hydra_type of a Fedora object" do
      rels_ext = fixture("rels_ext_cmodel.xml")
      result = @extractor.extract_rels_ext( rels_ext )
      result[:hydra_type_t].should == "salt_document"
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
      # result.should == {:facets=>{'box' => 'Box 51A', 'folder' => '15: Folder 15','series' => 'Accession 2005-101>', 'collection' => "Edward A. Feigenbaum Papers", "city"=>["Ann Arbor", "Hyderabad", "Palo Alto"], "person"=>["ELLIE ENGELMORE", "Reddy", "EDWARD FEIGENBAUM"], "title"=>"Letter from Ellie Engelmore to Professor K. C. Reddy", "technology"=>["artificial intelligence"], "year"=>"1985", "organization"=>["Heuristic Programming Project", "Mathematics and Computer/Information Sciences University of Hyderabad Central University P. O. Hyder", "Professor K. C. Reddy School of Mathematics and Computer/Information Sciences"], "state"=>["Michigan", "California"]}, :symbols=>{'box' => 'Box 51A', 'folder' => 'Folder 15', 'series' => 'eaf7000'}}
      result.should == {"city"=>["Ann Arbor", "Hyderabad", "Palo Alto"], "person"=>["ELLIE ENGELMORE", "Reddy", "EDWARD FEIGENBAUM"], "title"=>"Letter from Ellie Engelmore to Professor K. C. Reddy", "technology"=>["artificial intelligence"], "year"=>"1985", "organization"=>["Heuristic Programming Project", "Mathematics and Computer/Information Sciences University of Hyderabad Central University P. O. Hyder", "Professor K. C. Reddy School of Mathematics and Computer/Information Sciences"], "state"=>["Michigan", "California"]}#, :symbols=>{'box' => 'Box 51A', 'folder' => 'Folder 15', 'series' => 'eaf7000'}

    end
  end
  
  
end