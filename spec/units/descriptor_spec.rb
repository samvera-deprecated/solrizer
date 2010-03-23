require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Descriptor do
  
  # Relies on the descriptor registered by config/initializers/salt_descriptors.rb
  before(:each) do
    @descriptor = Shelver::Descriptor.retrieve("sc0340")
  end
  
  
  it "should expose a nokogiri interface for grabbing values from the ead" do
    @descriptor.xpath('//archdesc[@level="collection"]/did/unittitle').first.content.should == "Edward A. Feigenbaum Papers"
    @descriptor.xpath('//archdesc[@level="collection"]/did/unittitle').first.attribute("label").to_s.should == "Title"
    @descriptor.xpath('//archdesc[@level="collection"]/bioghist/p').first.content.should  == "Computer scientist. Feigenbaum received his B.S., 1956, and his Ph.D., 1959, in electrical engineering from Carnegie Institute of Technology. He completed a Fulbright Fellowship at the National Physics Laboratory and in 1960 went to the University of California, Berkeley, to teach in the School of Business Administration. He joined the Stanford faculty in 1965 in the Dept. of Computer Science; he served as Director of the Stanford Computation Center from 1965 to 1968 and as chairman of the Department from 1976 to 1981. Feigenbaum is a leading national figure in artificial intelligence and has developed computer resources for interactive research between medical and scientific collaborators on a national and global scale."
    
    s = @descriptor.xpath('//c01[@level="series"]').first
    s.xpath('did/unittitle').first.content.should == "Accession 1986-052>"
    #@descriptor.xpath('//archdesc[@level="collection"]/dsc[@type="in-depth"]/c01[@level="series"]/c02[@level="subseries"]/'
    #@descriptor.xpath('//did[head="Descriptive Summary"]').should = ""
    #@descriptor.xpath('//did[unittitle="Accession 2005-101>"]').should == ""

    #@descriptor.series["Accession 2005-101>"].children.xpath('/c02/c03/did[container[@type="box"]=1 and container[@type="folder"]=4]').should == "AAAI - American Association for Artificial Inteligence"
    @descriptor.xpath('//c01[did/unittitle="Accession 2005-101>"]//did[container[@type="box"]=1 and container[@type="folder"]=4]/unittitle').first.content.should == "AAAI - American Association for Artificial Inteligence1987 - 1995"
 
    node_name = "scopecontent"
    xpath_query = "//archdesc[@level=\"collection\"]/#{node_name}"
    response = ""
    response << "<dd> #{@descriptor.xpath( xpath_query + "/head" ).first.content} </dd>"
    response << "<dt> #{@descriptor.xpath( xpath_query + "/p" ).first.content} </dt>"
    # puts response
  end
  
  describe "lookup_folder_title" do
    it "should look up unittitle from the given combination of folder, series, and box" do
      @descriptor.lookup_folder_title(:series=>"Accession 1986-052>", :box=>"20", :folder=>"25").should == "J. R. Quinlan Visiting Scholar (1978)"
      # You must provide a series, box and folder!
      # These will not work:
      #@descriptor.lookup_title(:series=>"Accession 1986-052>")
    end
  end
  
  
end