# solrizer

[![Build Status](https://travis-ci.org/projecthydra/solrizer.png?branch=master)](https://travis-ci.org/projecthydra/solrizer)
[![Gem Version](https://badge.fury.io/rb/solrizer.png)](http://badge.fury.io/rb/solrizer)

A lightweight, configurable tool for indexing metadata into solr.  Can be triggered from within your application, from
the command line, or as a JMS listener.

Solrizer provides the baseline and structures for the process of solrizing.  In order to actually read objects from a
data source and write solr documents into a solr instance, you need to use an implementation specific gem, such as
"solrizer-fedora":https://github.com/projecthydra/solrizer-fedora, which provides the mechanics for reading from a
fedora repository and writing to a solr instance.


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

### Extractor and Extractor Mixins

Solrizer::Extractor provides utilities for extracting solr fields from objects or inserting solr fields into documents:

    > extractor = Solrizer::Extractor.new
    > solr_doc = Hash.new
    > extractor.format_node_value(["foo     ","\n      bar"])
    => "foo bar"
    > extractor.insert_solr_field_value(solr_doc, "foo","bar")
    => {"foo"=>"bar"}
    > extractor.insert_solr_field_value(solr_doc,"foo","baz")
    => {"foo"=>["bar", "baz"]}
    > extractor.insert_solr_field_value(solr_doc, "boo","hoo")
    => {"foo"=>["bar", "baz"], "boo"=>"hoo"}

#### Solrizer provides some default mixins:

`Solrizer::HTML::Extractor` provides html_to_solr method and `Solrizer::XML::Extractor` provides xml_to_solr method:

    > Solrizer::XML::Extractor
    > extractor = Solrizer::Extractor.new
    > xml = "<fields><foo>bar</foo><bar>baz</bar></fields>"
    > extractor.xml_to_solr(xml)
    => {:foo_tesim=>"bar", :bar_tesim=>"baz"}

#### Solrizer::XML::TerminologyBasedSolrizer

Another powerful mixin for use with classes that include the `OM::XML::Document` module is
`Solrizer::XML::TerminologyBasedSolrizer`. The methods provided by this module map provides a robust way of mapping
terms and solr fields via om terminologies. A notable example  can be found in `ActiveFedora::NokogiriDatatstream`.

## JMS Listener for Hydra Rails Applications

### The executables: solrizer and solrizerd

The solrizer gem provides two executables:

 * solrizer is a stomp consumer which listens for fedora.apim.updates and solrizes (or de-solrizes) objects accordingly. 
 * solrizerd is a wrapper script that spawns a daemonized version of solrizer and handles start|stop|restart|status requests. 

### Usage 

The usage for solrizerd is as follows: 

    solrizerd command --hydra_home PATH [options] 

The commands are as follows:
 *  start      start an instance of the application 
 *  stop       stop all instances of the application 
 *  restart    stop all instances and restart them afterwards 
 *  status     show status (PID) of application instances 

Required parameters:

--hydra_home: this is the path to your hydra rails applications' root directory.  Solrizerd needs this in order to load all your models and corresponding terminoligies.

The options:
 *  -p, --port         Stomp port  61613 
 *  -o, --host         Host to connect to  localhost 
 *  -u, --user         User name for stomp listener  
 *  -w, --password     Password for stomp listener  
 *  -d, --destination  Topic to listen to (default: /topic/fedora.apim.update) 
 *  -h, --help         Display this screen 

Note:

Since the solrizer script must fire up your hydra rails application, it must have all the gems installed that your hydra instance needs.

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
