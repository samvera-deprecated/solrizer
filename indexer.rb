
require 'solr'

load 'extractor.rb'

class Indexer

  #
  # Class variables
  #
  @@unique_id = 0

  def self.unique_id
    @@unique_id
  end

  #
  # Member variables
  #
  attr_accessor :connection, :extractor

  #
  # This method performs initialization tasks
  #
  def initialize()
    @extractor = Extractor.new
    connect
  end

  #
  # This method connects to the Solr instance
  #
  def connect
    @connection = Solr::Connection.new( SHELVER_SOLR_URL, :autocommit => :on )
  end

  #
  # This method extracts the full-text keywords from the given Fedora object's full-text datastream
  #
  def extract_full_text( obj, ds_name )
    full_text_ds = Repository.get_datastream( obj, ds_name )
    keywords = extractor.extractFullText( full_text_ds.content )
  end

  #
  # This method extracts the facet categories from the given Fedora object's external tag datastream
  #
  def extract_facet_categories( obj, ds_name )
    facet_ds = Repository.get_datastream( obj, ds_name )
    extractor.extractFacetCategories( facet_ds.content )
  end

  #
  # This method creates a Solr-formatted XML document
  #
  def create_document( obj )

    # retrieve a comprehensive list of all the datastreams associated with the given
    #   object and categorize each datastream based on its filename
    full_text_ds_names = Array.new
    facet_ds_names = Array.new
    ds_names = Repository.get_datastreams( obj )
    ds_names.each do |ds_name|
      if( ds_name =~ /.*.xml$/ and ds_name !~ /.*_TEXT.*/ and ds_name !~ /.*_METS.*/ and ds_name !~ /.*_LogicalStruct.*/ )
        full_text_ds_names << ds_name
      elsif( ds_name =~ /extProperties/ )
        facet_ds_names << ds_name
      end
    end

    # extract full-text
    keywords = String.new
    full_text_ds_names.each do |full_text_ds_name|
      keywords += extract_full_text( obj, full_text_ds_name )
    end

    # extract facet categories
    facets = extract_facet_categories( obj, facet_ds_names[0] )

    # create the Solr document
    solr_doc = Solr::Document.new
    solr_doc << Solr::Field.new( :id => "#{obj.pid}" )
    solr_doc << Solr::Field.new( :text => "#{keywords}" )
    facets.each { |key, value| solr_doc << Solr::Field.new( :"#{key}_facet" => "#{value}" ) }

    # increment the unique id to ensure that all documents in the search index are unique
    @@unique_id += 1

    return solr_doc
  end

  #
  # This method adds a document to the Solr search index
  #
  def index( obj )
    print "Indexing '#{obj.pid}'..."
    solr_doc = create_document( obj )
    connection.add( solr_doc )
    puts "done"
  end

  #
  # This method queries the Solr search index and returns a response
  #
  def query( query_str )
    response = conn.query( query_str )
  end

  #
  # This method prints out the results of the given query string by iterating through all the hits
  #
  def printResults( query_str )
    query( query_str ) do |hit|
      puts hit.inspect
    end
  end

  #
  # This method deletes a document from the Solr search index by id
  #
  def deleteDocument( id )
    connection.delete( id )
  end

  private :connect, :create_document, :extract_full_text, :extract_facet_categories

end

