#!/bin/env ruby

@index_full_text = false

require 'rubygems'
load 'configuration.rb'  
load 'repository.rb'  
load 'solrizer.rb'  

# initialize connection to Fedora repository
repository = Repository.new
repository.initialize_repository

# solrize all objects in the Fedora repository
solrizer = Solrizer.new
solrizer.solrize_objects

