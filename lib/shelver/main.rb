#!/bin/env ruby

@index_full_text = false

require 'rubygems'
load 'configuration.rb'  
load 'repository.rb'  
load 'shelver.rb'  

# initialize connection to Fedora repository
repository = Repository.new
repository.initialize_repository

# shelve all objects in the Fedora repository
shelver = Shelver.new
shelver.shelve_objects

