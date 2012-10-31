require 'bundler'
require 'rubygems'
require 'rake'

# load rake tasks in lib/tasks
Dir.glob('lib/tasks/*.rake').each { |r| import r }

Bundler::GemHelper.install_tasks

task :spec => ['solrizer:rspec']
task :rcov => ['solrizer:rcov']

task :default => :spec
