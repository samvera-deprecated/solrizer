# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "solrizer/version"

Gem::Specification.new do |s|
  s.name        = "solrizer"
  s.version     = Solrizer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Zumwalt"]
  s.email       = %q{hydra-tech@googlegroups.com}
  s.homepage    = %q{http://github.com/projecthydra/solrizer}
  s.summary     = %q{A utility for building solr indexes, usually from Fedora repository content with solrizer-fedora extension gem.}
  s.description = %q{Use solrizer to populate solr indexes.  You can run solrizer from within your app, using the provided rake tasks, or as a JMS listener}

  s.add_dependency "nokogiri"
  s.add_dependency "xml-simple"
  s.add_dependency "stomp"
  s.add_dependency "daemons"
  s.add_dependency "activesupport"
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'RedCloth' # yard depends on redcloth
    
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.require_paths = ["lib"]
end

