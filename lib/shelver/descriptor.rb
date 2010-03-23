require "nokogiri"

module Shelver
class Descriptor
  
  @@desctriptors = Hash[]
  attr_accessor :doc, :series
  
  def self.register(id="sc0340")
    @@desctriptors[id] = self.new( id )
  end
  
  def self.retrieve( id="sc0340" )
    if @@desctriptors[id].nil?
      self.register("sc0340")
    end
    return @@desctriptors[id]
  end
  
  def initialize(id="sc0340")
    @doc = load_data( id )
  end
  
  def xpath( args )
    @doc.xpath( args )
  end
  
  def lookup_folder_title( args={} ) 
    series = args[:series]
    box_name = args[:box]
    folder_name = args[:folder]
    
    xpath_query = "//c01[did/unittitle=\"#{series}\"]//did[container[@type=\"box\"]=#{box_name} and container[@type=\"folder\"]=#{folder_name}]/unittitle"
    #xpath_query = "//c01[did/unittitle=\"Accession 2005-101>\"]//did[container[@type=\"box\"]=1 and container[@type=\"folder\"]=4]/unittitle"

    return xpath( xpath_query ).first.content
  end
  
  private
  
  # REPLACE THIS.  Eventually, you will want to read this info from Fedora, taking a Fedora PID as the argument to the initializer.
  def load_data( id )
    file = File.new(File.join('lib', "stanford", "ead", id + ".xml"))
    doc = Nokogiri::XML( file )
    return doc
  end
  
  
end
end