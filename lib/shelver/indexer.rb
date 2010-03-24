require 'solr'
require 'shelver/extractor'
require 'shelver/repository'


module Shelver
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
  attr_accessor :connection, :extractor, :index_full_text

  #
  # This method performs initialization tasks
  #
  def initialize( opts={} )
    @@index_list = false unless defined?(@@index_list)
    @extractor = Extractor.new
    
    if opts[:index_full_text] == true || opts[:index_full_text] == "true"
      @index_full_text = true 
    else
      @index_full_text = false 
    end
    
    connect
  end

  #
  # This method connects to the Solr instance
  #
  def connect
    
    if defined?(Blacklight)
      solr_config = Blacklight.solr_config
    else
      
      if defined?(RAILS_ROOT)
        config_path = File.join(RAILS_ROOT, "config")
        yaml = YAML.load(File.open(File.join(config_path, "solr.yml")))
        solr_config = yaml[RAILS_ENV]
      else
        config_path = File.join(File.dirname(__FILE__), "..", "..", "config")
        yaml = YAML.load(File.open(File.join(config_path, "solr.yml")))
        
        
        if ENV["environment"].nil?
          environment = "development"
        else
          environment = ENV["environment"]
        end
        
        solr_config = yaml[environment]
        puts solr_config.inspect
      end
      
    end
        
    if index_full_text == true
      url = solr_config['fulltext']['url']
    else
      url = solr_config['default']['url']
    end
    @connection = Solr::Connection.new(url, :autocommit => :on )
  end

  #
  # This method extracts the facet categories from the given Fedora object's external tag datastream
  #
  def extract_xml_to_solr( obj, ds_name, solr_doc=Solr::Document.new )
    xml_ds = Repository.get_datastream( obj, ds_name )
    extractor.xml_to_solr( xml_ds.content, solr_doc )
  end
  
  #
  #
  #
  def extract_rels_ext( obj, ds_name, solr_doc=Solr::Document.new )
    rels_ext_ds = Repository.get_datastream( obj, ds_name )
    extractor.extract_rels_ext( rels_ext_ds.content, solr_doc )
  end
  
  #
  # This method generates the month and day facets from the date_t in solr_doc
  #
  
  def generate_dates(solr_doc)
    
    # This will check for valid dates, but it seems most of the dates are currently invalid....
    #date_check =  /^(19|20)\d\d([- \/.])(0[1-9]|1[012])\2(0[1-9]|[12][0-9]|3[01])/

   #if there is not date_t, add on with easy-to-find value
   if solr_doc[:date_t].nil?
        solr_doc << Solr::Field.new( :date_t => "9999-99-99")
   end #if

    # unless date_check !~  solr_doc[:date_t]     
    date_obj = Date._parse(solr_doc[:date_t])
    
    if date_obj[:mon].nil? 
       solr_doc << Solr::Field.new(:month_facet => 99)
    elsif 0 < date_obj[:mon] && date_obj[:mon] < 13
      solr_doc << Solr::Field.new( :month_facet => date_obj[:mon].to_s.rjust(2, '0'))
    else
      solr_doc << Solr::Field.new( :month_facet => 99)
    end
      
    if  date_obj[:mday].nil?
      solr_doc << Solr::Field.new( :day_facet => 99)
    elsif 0 < date_obj[:mday] && date_obj[:mday] < 32   
      solr_doc << Solr::Field.new( :day_facet => date_obj[:mday].to_s.rjust(2, '0'))
    else
       solr_doc << Solr::Field.new( :day_facet => 99)
    end
    
    return solr_doc
#      end
        
  end
  
  
  #
  # This method creates a Solr-formatted XML document
  #
  def create_document( obj )
    
    # retrieve a comprehensive list of all the datastreams associated with the given
    #   object and categorize each datastream based on its filename
    ext_properties_ds_names, rels_ext_names, properties_ds_names, stories_ds_names, full_text_ds_names, xml_ds_names, jp2_ds_names,  = [],[],[],[],[],[],[],[] 
    ds_names = Repository.get_datastreams( obj )
    
    ds_names.each do |ds_name|
      if ds_name =~ /descMetadata/ 
        xml_ds_names << ds_name
      elsif ds_name =~ /^properties/
        properties_ds_names << ds_name
        xml_ds_names << ds_name
      elsif ds_name =~ /^RELS-EXT/
        rels_ext_names << ds_name
      end
    end
        
    # create the Solr document
    solr_doc = Solr::Document.new
    solr_doc << Solr::Field.new( :id => "#{obj.pid}" )
    solr_doc << Solr::Field.new( :id_t => "#{obj.pid}" )
   
        
    # Pass the solr_doc through extract_simple_xml_to_solr   
      xml_ds_names.each { |ds_name| extract_xml_to_solr(obj, ds_name, solr_doc)}
    
    # Generate month_facet and day_facet from date_t value
      generate_dates(solr_doc)
      
    # extract RELS-EXT
    rels_ext_names.each { |ds_name| extract_rels_ext(obj, ds_name, solr_doc)}
    
    # increment the unique id to ensure that all documents in the search index are unique
    @@unique_id += 1

    return solr_doc
  end

  #
  # This method adds a document to the Solr search index
  #
  def index( obj )
   # print "Indexing '#{obj.pid}'..."
    begin
      
      solr_doc = create_document( obj )
      connection.add( solr_doc )
 
     # puts connection.url
     #puts solr_doc
     #  puts "done"
   
    rescue Exception => e
       p "unable to index #{obj.pid}.  Failed with #{e.inspect}"
    end
   
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
  
  # Populates a solr doc with values from a hash.  
  # Accepts two forms of hashes:
  # => {'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]}
  # or
  # => {:facets => {'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]} }
  #
  # Note that values for individual fields can be a single string or an array of strings.
  def self.solrize( input_hash, solr_doc=Solr::Document.new )    
    facets = input_hash.has_key?(:facets) ? input_hash[:facets] : input_hash
    facets.each_pair do |facet_name, value|
      case value.class.to_s
      when "String"
        solr_doc << Solr::Field.new( :"#{facet_name}_facet" => "#{value}" )
      when "Array"
        value.each { |v| solr_doc << Solr::Field.new( :"#{facet_name}_facet" => "#{v}" ) } 
      end
    end
    
    if input_hash.has_key?(:symbols) 
      input_hash[:symbols].each do |symbol_name, value|
        case value.class.to_s
        when "String"
          solr_doc << Solr::Field.new( :"#{symbol_name}_s" => "#{value}" )
	      when "Array"
          value.each { |v| solr_doc << Solr::Field.new( :"#{symbol_name}_s" => "#{v}" ) } 
        end
      end
    end
    return solr_doc
  end
  

  private :connect, :create_document

end
end
