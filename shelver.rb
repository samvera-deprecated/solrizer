
load 'indexer.rb'

class Shelver

  attr_accessor :indexer

  #
  # This method initializes the indexer
  #
  def initialize()
    @indexer = Indexer.new
  end

  #
  # This method shelves the given Fedora object's full-text and facets into the search index
  #
  def shelve_object( pid )
    # retrieve the Fedora object based on the given unique id
    obj = Repository.get_object( pid )
    # add the keywords and facets to the search index
    indexer.index( obj )
  end
  
  #
  # This method retrieves a comprehensive list of all the unique identifiers in Fedora and 
  # shelves each object's full-text and facets into the search index
  #
  def shelve_objects
    # retrieve a list of all the pids in the fedora repository
    num_docs = 1000000   # modify this number to guarantee that all the objects are retrieved from the repository
    pids = Repository.get_pids( num_docs )
    puts "Shelving #{pids.length} Fedora objects"
    pids.each do |pid|
      shelve_object( pid )
    end
  end

end

