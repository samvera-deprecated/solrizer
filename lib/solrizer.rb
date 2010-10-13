require 'rubygems'
require 'solrizer/field_mapper.rb'
require 'solrizer/indexer.rb'

# Let people explicitly require xml support if they want it ...
# require 'solrizer/xml.rb'

# require 'fastercsv'
require "ruby-debug"


module Solrizer
class Solrizer

  attr_accessor :indexer, :index_full_text

  #
  # This method initializes the indexer
  # If passed an argument of :index_full_text=>true, it will perform full-text indexing instead of indexing fields only.
  #
  def initialize( opts={} )
    @@index_list = false unless defined?(@@index_list)
    if opts[:index_full_text] == true || opts[:index_full_text] == "true"
      @index_full_text = true 
    else
      @index_full_text = false 
    end
    @indexer = Indexer.new( :index_full_text=>@index_full_text )
  end

  #
  # This method solrizes the given Fedora object's full-text and facets into the search index
  #
  def solrize( obj )
    # retrieve the Fedora object based on the given unique id
      
      begin
      
      start = Time.now
      print "Retrieving object #{obj} ..."

      case obj
      when ActiveFedora::Base
        # do nothing
      when Fedora::FedoraObject
        obj = Repository.get_object( obj.pid )
      when String
        obj = Repository.get_object( obj )
      else
        raise "you must pass either a ActiveFedora::Base, Fedora::RepositoryObject, or a String.  You submitted a #{obj.class}"
      end
      
      # obj = obj.kind_of?(ActiveFedora::Base) ? obj : Repository.get_object( obj )
        
          obj_done = Time.now
          obj_done_elapse = obj_done - start
          puts  " completed. Duration: #{obj_done_elapse}"
          
         print "\t Indexing object #{obj.pid} ... "
         # add the keywords and facets to the search index
         index_start = Time.now
         indexer.index( obj )
         
         index_done = Time.now
         index_elapsed = index_done - index_start
         
          puts "completed. Duration:  #{index_elapsed} ."
        
      
      rescue Exception => e
           p "unable to index #{obj}.  Failed with #{e.inspect}"
        
      
      end #begin
  
  end

  ###
  # This method will delete an object from solr
  ###
  def solrize_delete( id )
    begin
    
      print "\t Deleting object #{id} ... "
      # add the keywords and facets to the search index
      delete_start = Time.now
      indexer.deleteDocument( id )
         
      delete_done = Time.now
      delete_elapsed = delete_done - delete_start
         
      puts "completed. Duration:  #{delete_elapsed} ."
        
      
    rescue Exception => e
      p "unable to delete #{id}.  Failed with #{e.inspect}"
        
      
    end #begin
  end
  
  #
  # This method retrieves a comprehensive list of all the unique identifiers in Fedora and 
  # solrizes each object's full-text and facets into the search index
  def solrize_objects
    # retrieve a list of all the pids in the fedora repository
    num_docs = 1000000   # modify this number to guarantee that all the objects are retrieved from the repository
    puts "WARNING: You have turned off indexing of Full Text content.  Be sure to re-run indexer with @@index_full_text set to true in main.rb" if index_full_text == false

    if @@index_list == false
      
      objects = Fedora::Repository.instance.find_objects(:limit=>num_docs)

      puts "Shelving #{objects.length} Fedora objects"
      objects.each do |object|
        solrize( object )
      end
     
    else
    
       if File.exists?(@@index_list)
          arr_of_pids = FasterCSV.read(@@index_list, :headers=>false)
          
          puts "Indexing from list at #{@@index_list}"
          puts "Shelving #{arr_of_pids.length} Fedora objects"
          
         arr_of_pids.each do |row|
            pid = row[0]
            solrize( pid )
	 end #FASTERCSV
        else
          puts "#{@@index_list} does not exists!"
        end #if File.exists
     
    end #if Index_LISTS
  end #solrize_objects

end #class
end #module
