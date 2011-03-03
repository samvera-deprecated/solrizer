# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{solrizer}
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Zumwalt"]
  s.date = %q{2011-03-03}
  s.description = %q{Use solrizer to populate solr indexes from Fedora repository content or from other sources.  You can run solrizer from within your apps, using the provided rake tasks, or as a JMS listener}
  s.email = %q{matt.zumwalt@yourmediashelf.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.textile"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "History.txt",
    "LICENSE",
    "README.textile",
    "Rakefile",
    "VERSION",
    "config/fedora.yml",
    "config/hydra_types.yml",
    "config/solr.yml",
    "config/solr_mappings.yml",
    "config/solr_mappings_af_0.1.yml",
    "lib/solrizer.rb",
    "lib/solrizer/extractor.rb",
    "lib/solrizer/field_mapper.rb",
    "lib/solrizer/field_name_mapper.rb",
    "lib/solrizer/html.rb",
    "lib/solrizer/html/extractor.rb",
    "lib/solrizer/xml.rb",
    "lib/solrizer/xml/extractor.rb",
    "lib/solrizer/xml/terminology_based_solrizer.rb",
    "lib/tasks/solrizer.rake",
    "solrizer.gemspec",
    "spec/.rspec",
    "spec/fixtures/druid-bv448hq0314-descMetadata.xml",
    "spec/fixtures/druid-bv448hq0314-extProperties.xml",
    "spec/fixtures/druid-cm234kq4672-extProperties.xml",
    "spec/fixtures/druid-cm234kq4672-stories.xml",
    "spec/fixtures/druid-hc513kw4806-descMetadata.xml",
    "spec/fixtures/mods_articles/hydrangea_article1.xml",
    "spec/fixtures/test_solr_mappings.yml",
    "spec/rcov.opts",
    "spec/spec_helper.rb",
    "spec/units/extractor_spec.rb",
    "spec/units/field_mapper_spec.rb",
    "spec/units/field_name_mapper_spec.rb",
    "spec/units/xml_extractor_spec.rb",
    "spec/units/xml_terminology_based_solrizer_spec.rb"
  ]
  s.homepage = %q{http://github.com/projecthydra/solrizer}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A utility for building solr indexes, usually from Fedora repository content.}
  s.test_files = [
    "spec/spec_helper.rb",
    "spec/units/extractor_spec.rb",
    "spec/units/field_mapper_spec.rb",
    "spec/units/field_name_mapper_spec.rb",
    "spec/units/xml_extractor_spec.rb",
    "spec/units/xml_terminology_based_solrizer_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<xml-simple>, [">= 0"])
      s.add_runtime_dependency(%q<om>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<mediashelf-loggable>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug-base>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["< 2.0.0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<om>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<mediashelf-loggable>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug-base>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["< 2.0.0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<xml-simple>, [">= 0"])
      s.add_dependency(%q<om>, [">= 1.0.0"])
      s.add_dependency(%q<mediashelf-loggable>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<ruby-debug-base>, [">= 0"])
      s.add_dependency(%q<rspec>, ["< 2.0.0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<om>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<mediashelf-loggable>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<ruby-debug-base>, [">= 0"])
      s.add_dependency(%q<rspec>, ["< 2.0.0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<xml-simple>, [">= 0"])
    s.add_dependency(%q<om>, [">= 1.0.0"])
    s.add_dependency(%q<mediashelf-loggable>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<ruby-debug-base>, [">= 0"])
    s.add_dependency(%q<rspec>, ["< 2.0.0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<om>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<mediashelf-loggable>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<ruby-debug-base>, [">= 0"])
    s.add_dependency(%q<rspec>, ["< 2.0.0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end

