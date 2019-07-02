## Note: This project has been deprecated and is no longer being maintained.
The functionality previously provided by solrizer has been refactored directly into the [ActiveFedora](https://github.com/samvera/active_fedora#activefedora) gem.  If you require fucntionality previously provided by this gem, you should generally be able to include `active-fedora` in your Gemfile instead.  See especially [default_descriptors.rb](https://github.com/samvera/active_fedora/blob/12.0-stable/lib/active_fedora/indexing/default_descriptors.rb) and `solr_name` in [field_mapper.rb](https://github.com/samvera/active_fedora/blob/12.0-stable/lib/active_fedora/indexing/field_mapper.rb#L28)

# solrizer

[![Build Status](https://circleci.com/gh/samvera/solrizer.svg?style=svg)](https://circleci.com/gh/samvera/solrizer)
[![Gem Version](https://badge.fury.io/rb/solrizer.png)](http://badge.fury.io/rb/solrizer)
[![Dependencies](https://gemnasium.com/projecthydra/solrizer.png)](https://gemnasium.com/projecthydra/solrizer)
[![Coverage Status](https://img.shields.io/coveralls/projecthydra/solrizer.svg)](https://coveralls.io/r/projecthydra/solrizer)


A lightweight tool for creating dynamic solr schema sufixes.


## Installation

The gem is hosted on [rubygems.org](https://rubygems.org/gems/solrizer). The best way to manage the gems for your project
is to use bundler.  Create a Gemfile in the root of your application and include the following:


    source "https://rubygems.org"
    gem 'solrizer'

Then:

    bundle install

## Usage

### Fire up the console:

The code snippets in the following sections can be cut/pasted into your console, giving you the opportunity to play with Solrizer.

Start up a console and load solrizer:

    > irb
    > require "rubygems"
    > require "solrizer"

### Field Mapper

The `FieldMapper` maps term names and values to Solr fields, based on the term's data type and any index_as options.
Solrizer comes with default mappings to dynamic field types defined in the Hydra Solr 
[schema.xml](https://github.com/projecthydra/hydra-head/blob/master/hydra-core/lib/generators/hydra/templates/solr_conf/conf/schema.xml).
	
More information on the conventions followed for the dynamic solr fields is on the 
[wiki page](https://github.com/projecthydra/hydra-head/wiki/Solr-Schema).

To examine all of Solrizer's field names, open up a ruby console:


    > require 'solrizer'
    => true
    > default_mapper = Solrizer::FieldMapper.new
    => #<Solrizer::FieldMapper:0x007fb47a273770 @id_field="id">
    > default_mapper.solr_name("foo",:searchable, type: :string)
    => "foo_teim"
    > default_mapper.solr_name("foo",:searchable, type: :date)
    => "foo_dtim"
    > default_mapper.solr_name("foo",:searchable, type: :integer)
    => "foo_iim"
    > default_mapper.solr_name("foo",:facetable, type: :string)
    => "foo_sim"
    > default_mapper.solr_name("foo",:facetable, type: :integer)
    => "foo_sim"
    > default_mapper.solr_name("foo",:sortable, type: :string)
    => "foo_si"
    > default_mapper.solr_name("foo",:displayable, type: :string)
    => "foo_ssm"

### Default indexing strategies

    > solr_doc = Hash.new
    > Solrizer.insert_field(solr_doc, 'title', 'whatever', :stored_searchable) 
    => {"title_tesim"=>["whatever"]}

    > Solrizer.insert_field(solr_doc, 'pub_date', 'Nov 2012', :sortable, :displayable) 
    => {"pub_date_si"=>"Nov 2012", "pub_date_ssm"=>["Nov 2012"]}

### Indexing dates

as a date:

    > solr_doc = {}
    > Solrizer.insert_field(solr_doc, 'pub_date', Date.parse('Nov 7th 2012'), :searchable)
    => {"pub_date_dtim"=>["2012-11-07T00:00:00Z"]}

or as a string:

    > solr_doc = {}
    > Solrizer.insert_field(solr_doc, 'pub_date', Date.parse('Nov 7th 2012'), :sortable, :displayable)
    => {"pub_date_dti"=>"2012-11-07T00:00:00Z", "pub_date_ssm"=>["2012-11-07"]}

or a string that is stored as a date:

    > solr_doc = {}
    > Solrizer.insert_field(solr_doc, 'pub_date', 'Jan 29th 2013', :dateable)
    => {"pub_date_dtsim"=>["2013-01-29T00:00:00Z"]}

### Custom indexing strategies

#### Create your own index descriptor

    > solr_doc = {}
    > displearchable = Solrizer::Descriptor.new(:integer, :indexed, :stored)
    > Solrizer.insert_field(solr_doc, 'some_count', 45, displearchable)
    => {"some_count_isi"=>"45"}

#### Override the defaults

We can override the default indexing methods within `Solrizer::DefaultDescriptors`

Here's the default behavior:

    > solr_doc = {}
    > Solrizer.insert_field(solr_doc, 'title', 'foobar', :facetable)
    => {"title_sim"=>["foobar"]}

But let's override that by redefining `:facetable`

    module Solrizer
      module DefaultDescriptors
        def self.facetable
          Descriptor.new(:string, :indexed, :stored)
        end
      end
    end

Now, `:facetable` will return something different:

    > solr_doc = {}
    > Solrizer.insert_field(solr_doc, 'title', 'foobar', :facetable)
    => {"title_ssi"=>"foobar"}

#### Creating your own indexers

    module MyMappers
      def self.mapper_one
        Solrizer::Descriptor.new(:string, :indexed, :stored)
      end
    end

Now, set Solrizer's field mapper to use our new module:

    > solr_doc = {}
    > Solrizer::FieldMapper.descriptors = [MyMappers]
    => [MyMappers]
    > Solrizer.insert_field(solr_doc, 'title', 'foobar', :mapper_one)
    => {"title_ssi"=>"foobar"}

### Using OM

    t.main_title(:index_as=>[:facetable],:path=>"title", :label=>"title") { ... }

But now you may also pass an Descriptor instance if that works for you:

    indexer = Solrizer::Descriptor.new(:integer, :indexed, :stored)
    t.main_title(:index_as=>[indexer],:path=>"title", :label=>"title") { ... }

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rake file, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Acknowledgments

### Technical Lead

Matt Zumwalt ("MediaShelf":http://yourmediashelf.com)

### Thanks to 

* Douglas Kim, who created the initial code base for Solrizer. 
* Chris Fitzpatrick, who patiently ran the first prototype through its paces for weeks.
* Bess Sadler, who created the JMS integration for Solrizer, generously served as a sounding board for numerous design issues around solr indexing, and pushes the technology forward with the skill of a true engineer.

## Copyright

Copyright (c) 2010 Matt Zumwalt. See LICENSE for details.
