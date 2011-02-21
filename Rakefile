require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "solrizer"
    gem.summary = %Q{A utility for building solr indexes, usually from Fedora repository content.}
    gem.description = %Q{Use solrizer to populate solr indexes from Fedora repository content or from other sources.  You can run solrizer from within your apps, using the provided rake tasks, or as a JMS listener}
    gem.email = "matt.zumwalt@yourmediashelf.com"
    gem.homepage = "http://github.com/projecthydra/solrizer"
    gem.authors = ["Matt Zumwalt"]
    gem.add_dependency "solr-ruby"
    gem.add_dependency "nokogiri"
    gem.add_dependency "om"
    gem.add_dependency "nokogiri"
    gem.add_dependency "mediashelf-loggable"
    gem.add_development_dependency "jeweler"
    gem.add_development_dependency 'ruby-debug'
    gem.add_development_dependency 'ruby-debug-base'
    gem.add_development_dependency 'rspec', '<2.0.0'
    gem.add_development_dependency 'mocha'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

# task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "solrizer #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
