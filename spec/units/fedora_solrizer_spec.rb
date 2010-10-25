require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Solrizer::Fedora::Solrizer do
  
  before(:each) do
    @solrizer = Solrizer::Fedora::Solrizer.new
  end
  
  describe "solrize" do
    it "should trigger the indexer for the provided object" do
      sample_obj = ActiveFedora::Base.new
      @solrizer.indexer.expects(:index).with( sample_obj )
      @solrizer.solrize( sample_obj )
    end
    it "should work with Fedora::FedoraObject objects" do
      mock_object = Fedora::FedoraObject.new(:pid=>"my:pid", :label=>"my label")
      ActiveFedora::Base.expects(:load_instance).with( mock_object.pid ).returns(mock_object)
      @solrizer.indexer.expects(:index).with( mock_object )
      @solrizer.solrize( mock_object )
    end
    it "should load the object if only a pid is provided" do
      mock_object = mock("my object")
      mock_object.stubs(:pid)
      mock_object.stubs(:label)
      mock_object.stubs(:datastreams).returns({'descMetadata'=>"foo","location"=>"bar"})

      ActiveFedora::Base.expects(:load_instance).with( "_PID_" ).returns(mock_object)
      @solrizer.indexer.expects(:index).with(mock_object)
      @solrizer.solrize("_PID_")
    end

  end
  
  describe "solrize_objects" do
    it "should call solrize for each object returned by Fedora::Repository.find_objects" do
      objects = [["pid1"], ["pid2"], ["pid3"]]
      Fedora::Repository.any_instance.expects(:find_objects).returns(objects)
      objects.each {|object| @solrizer.expects(:solrize).with( object ) }
      @solrizer.solrize_objects
    end
  end
end