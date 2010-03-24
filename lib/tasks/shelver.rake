namespace :shelver do
  
  desc 'Index a fedora object of the given pid.'
  task :shelve_object => :environment do 
    index_full_text = ENV['FULL_TEXT'] == 'true'
    if ENV['PID']
      puts "indexing #{ENV['PID'].inspect}"
      shelver = Shelver::Shelver.new :index_full_text=> index_full_text
      shelver.shelve_object(ENV['PID'])
      puts "Finished shelving #{ENV['PID']}"
    else
      puts "You must provide a pid using the format 'shelver::shelve_object PID=sample:pid'."
    end
  end
  
  desc 'Index all objects in the repository.'
  task :shelve_objects => :environment do
    index_full_text = ENV['FULL_TEXT'] == 'true'
    if ENV['INDEX_LIST']
      @@index_list = ENV['INDEX_LIST']
    end
    
    puts "Re-indexing Fedora Repository."
    puts "Fedora URL: #{ActiveFedora.fedora_config[:url]}"
    puts "Fedora Solr URL: #{ActiveFedora.solr_config[:url]}"
    puts "Blacklight Solr Config: #{Blacklight.solr_config.inspect}"
    puts "Doing full text index." if index_full_text
    shelver = Shelver::Shelver.new :index_full_text=> index_full_text
    shelver.shelve_objects
    puts "Shelver task complete."
  end  
  
end
