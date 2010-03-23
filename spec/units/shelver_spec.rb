require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Shelver::Shelver do
  
  before(:each) do
    @shelver = Shelver::Shelver.new
  end
  
  describe "shelve_object" do
    it "should trigger the indexer for the provided object" do
      # sample_obj = ActiveFedora::Base.new
      mock_object = mock("my object")
      mock_object.expects(:kind_of?).with(ActiveFedora::Base).returns(true)
      mock_object.stubs(:pid)
      mock_object.stubs(:label)
      mock_object.stubs(:datastreams).returns({'descMetadata'=>"foo","location"=>"bar"})
      ActiveFedora::Base.expects(:load_instance).never
      @shelver.indexer.expects(:index).with( mock_object )
      @shelver.shelve_object( mock_object )
    end
    it "should still load the object if only a pid is provided" do
      mock_object = mock("my object")
      mock_object.stubs(:pid)
      mock_object.stubs(:label)
      mock_object.stubs(:datastreams).returns({'descMetadata'=>"foo","location"=>"bar"})

      ActiveFedora::Base.expects(:load_instance).with( "_PID_" ).returns(mock_object)
      @shelver.indexer.expects(:index).with(mock_object)
      @shelver.shelve_object("_PID_")
    end
  end
  
  describe "shelve_objects" do
    it "should call shelve_object for each pid returned by solr" do
      pids = [["pid1"], ["pid2"], ["pid3"]]
      Shelver::Repository.expects(:get_pids).returns(pids)
      pids.each {|pid| @shelver.expects(:shelve_object).with( pid ) }
      @shelver.shelve_objects
    end
  end
end