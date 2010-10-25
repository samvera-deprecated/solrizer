require 'active-fedora'

module Solrizer::Fedora
class Repository

  #
  # This method retrieves a comprehensive list of unique ids in the fedora repository
  #
  def self.get_pids( num_docs )
    solr_results = ActiveFedora::SolrService.instance.conn.query( "active_fedora_model_field:Document", { :rows => num_docs } )
    id_array = []
    solr_results.hits.each do |hit|
      id_array << hit[SOLR_DOCUMENT_ID]
    end
    return id_array
  end
  
  #
  # This method retrieves the object associated with the given unique id
  #
  def self.get_object( pid )
    object = ActiveFedora::Base.load_instance( pid )
  end
  
  #
  # This method retrieves a comprehensive list of datastreams for the given object
  #
  def self.get_datastreams( obj )
    ds_keys = obj.datastreams.keys
  end
  
  #
  # This method retrieves the datastream for the given object with the given datastream name
  #
  def self.get_datastream( obj, ds_name )
    begin
      obj.datastreams[ ds_name ]
    rescue
      return nil
    end
  end

end
end
