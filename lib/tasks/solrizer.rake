namespace :solrizer do
  
  desc 'Placeholder for generic solrization task.'
  task :solrize do
    puts "Nobody here.  Possibly you meant to run rake solrizer:fedora:solrize PID=..."
  end
  
  desc 'Placeholder for generic solrization task.'
  task :solrize_objects do
    puts "Nobody here.  Possibly you meant to run rake solrizer:fedora:solrize_objects"
  end
  
  namespace :fedora  
    desc 'Index a fedora object of the given pid.'
    task :solrize => :environment do 
      index_full_text = ENV['FULL_TEXT'] == 'true'
      if ENV['PID']
        puts "indexing #{ENV['PID'].inspect}"
        solrizer = Solrizer::Fedora::Solrizer.new :index_full_text=> index_full_text
        solrizer.solrize(ENV['PID'])
        puts "Finished shelving #{ENV['PID']}"
      else
        puts "You must provide a pid using the format 'solrizer::solrize_object PID=sample:pid'."
      end
    end
  
    desc 'Index all objects in the repository.'
    task :solrize_objects => :environment do
      index_full_text = ENV['FULL_TEXT'] == 'true'
      if ENV['INDEX_LIST']
        @@index_list = ENV['INDEX_LIST']
      end
    
      puts "Re-indexing Fedora Repository."
      puts "Fedora URL: #{ActiveFedora.fedora_config[:url]}"
      puts "Fedora Solr URL: #{ActiveFedora.solr_config[:url]}"
      puts "Blacklight Solr Config: #{Blacklight.solr_config.inspect}"
      puts "Doing full text index." if index_full_text
      solrizer = Solrizer::Fedora::Solrizer.new :index_full_text=> index_full_text
      solrizer.solrize_objects
      puts "Solrizer task complete."
    end  
  end
  
end
