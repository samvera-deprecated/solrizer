require 'fastercsv'
REPLICATOR_LIST = false unless defined?(REPLICATOR_LIST)


module Solrizer
  class Replicator
    
    include Stanford::SaltControllerHelper
    attr_accessor :dest_repo, :configs
    
    def initialize
      config_path = "#{RAILS_ROOT}/config/replicator.yml"
      raw_configs = YAML::load(File.open(config_path))
      @configs = raw_configs[RAILS_ENV]
      @dest_repo = Fedora::Repository.new(configs["destination"]["fedora"]["url"])
      
      ActiveFedora.fedora_config[:url] = configs["source"]["fedora"]["url"]
      logger.info("REPLICATOR: re-initializing Fedora with fedora_config: #{ActiveFedora.fedora_config.inspect}")
 
      Fedora::Repository.register(ActiveFedora.fedora_config[:url])
      logger.info("REPLICATOR: re-initialized Fedora as: #{Fedora::Repository.instance.inspect}")
      
      # Register Solr
      ActiveFedora.solr_config[:url] = configs["source"]["solr"]["url"]
      
      logger.info("REPLICATOR: re-initializing ActiveFedora::SolrService with solr_config: #{ActiveFedora.solr_config.inspect}")
 
      ActiveFedora::SolrService.register(ActiveFedora.solr_config[:url])
      
    end
    
    def replicate_objects
     # retrieve a list of all the pids in the fedora repository
      num_docs = 1000000   # modify this number to guarantee that all the objects are retrieved from the repository

      if REPLICATOR_LIST == false

         pids = Repository.get_pids( num_docs )
         puts "Replicating #{pids.length} Fedora objects"
          pids.each do |pid|
            unless pid[0].empty? || pid[0].nil? || !pid[0].include?("druid:")
              puts "Processing #{pid}"
              replicate_object( pid )
            end #unless
          end #pids.each

      else

         if File.exists?(REPLICATOR_LIST)
            arr_of_pids = FasterCSV.read(REPLICATOR_LIST, :headers=>false)

            puts "Replicating from list at #{REPLICATOR_LIST}"
            puts "Replicating #{arr_of_pids.length} Fedora objects"

           arr_of_pids.each do |row|
              pid = row[0]
              replicate_object( pid )   
           end #FASTERCSV
           
          else
            puts "#{REPLICATOR_LIST} does not exists!"
          end #if File.exists

      end #if Index_LISTS
    end #replicate_objects

 
    def replicate_object(obj)
	#source_doc = Document.load_instance(pid)
       obj = obj.kind_of?(ActiveFedora::Base) ? obj : Repository.get_object( obj )
	     p "Indexing object #{obj.pid} with label #{obj.label}"
      begin
        unless obj.nil?
		      create_stub(obj)
        	p "Successfully replicated #{obj.pid}"
   	    end  
      rescue Exception => e
        p "unable to create stub.  Failed with #{e.inspect}"
      end
    end
    
    # Creates a stub object in @dest_repo with the datastreams that we need in the stubs
    def create_stub(source_object)
      
      begin
        
       jp2 = downloadables(source_object, :canonical=>true, :mime_type=>"image/jp2")   
       jp2.new_object = true
       jp2.control_group = 'M'
       jp2.blob = jp2.content
      
       	stub_object = Fedora::FedoraObject.new(:pid=>source_object.pid)
       	dest_repo.save(stub_object)   
	      dest_repo.save(jp2)
      
      ["properties", "extProperties", "descMetadata", "location"].each do |ds_name|
        ds = source_object.datastreams[ds_name]
        ds.new_object = true
        ds.blob = ds.content
        dest_repo.save(ds)
      end
     
     rescue
         #for object without jp2s
         #this is a temp fix to the downloadables() issue
         
         
         pid = source_object.pid 
	        p "> #{pid}"
        
          jp2_file = File.new('spec/fixtures/image.jp2')
          ds = ActiveFedora::Datastream.new(:dsID => "image.jp2", :dsLabel => 'image.jp2', :controlGroup => 'M', :blob => jp2_file)
	        source_object.add_datastream(ds)
          source_object.save 
	        #  source_object = Document.load_instance(pid)
 	        source_object = ActiveFedora::Base.load_instance(pid)
       	  stub_object = Fedora::FedoraObject.new(:pid=>source_object.pid)
          dest_repo.save(stub_object)
         
          jp2 = downloadables(source_object, :canonical=>true, :mime_type=>"image/jp2")   
          jp2.new_object = true
          jp2.control_group = 'M'
          jp2.blob = jp2.content

          	stub_object = Fedora::FedoraObject.new(:pid=>source_object.pid)
          	dest_repo.save(stub_object)   
   	      dest_repo.save(jp2)

         ["properties", "extProperties", "descMetadata", "location"].each do |ds_name|
           ds = source_object.datastreams[ds_name]
           ds.new_object = true
           ds.blob = ds.content
           dest_repo.save(ds)
         end  
    
      end    
    end
    def logger
      @logger ||= defined?(RAILS_DEFAULT_LOGGER) ? RAILS_DEFAULT_LOGGER : Logger.new(STDOUT)
    end
    
  end
end
