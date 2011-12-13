require 'bundler'
require 'rubygems'
require 'rake'

# load rake tasks in lib/tasks
Dir.glob('lib/tasks/*.rake').each { |r| import r }

Bundler::GemHelper.install_tasks

task :spec => ['solrizer:rspec']
task :rcov => ['solrizer:rcov']

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "solrizer #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
