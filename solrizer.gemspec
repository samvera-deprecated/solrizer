# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "solrizer/version"

Gem::Specification.new do |s|
  s.name        = "solrizer"
  s.version     = Solrizer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Zumwalt"]
  s.email       = %q{matt.zumwalt@yourmediashelf.com}
  s.homepage    = %q{http://github.com/projecthydra/solrizer}
  s.summary     = %q{A utility for building solr indexes, usually from Fedora repository content.}
  s.description = %q{Use solrizer to populate solr indexes from Fedora repository content or from other sources.  You can run solrizer from within your apps, using the provided rake tasks, or as a JMS listener}

  s.add_dependency "nokogiri"
  s.add_dependency "om", ">=1.4.0"
  s.add_dependency "xml-simple"
  s.add_dependency "mediashelf-loggable"
  s.add_dependency "stomp"
  s.add_dependency "daemons"
  s.add_development_dependency 'ruby-debug'
  s.add_development_dependency 'ruby-debug-base'
  s.add_development_dependency 'rspec', '<2.0.0'
  s.add_development_dependency 'rcov'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'RedCloth'
    
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [
    "LICENSE",
    "README.textile"
  ]
  s.require_paths = ["lib"]
end

