# require 'rubygems'
# gem 'mocha'
# require 'mocha'
# require 'ruby-fedora'
# begin
#   require 'spec'
# rescue LoadError
#   gem 'rspec'
#   require 'spec'
# end


$:.unshift(File.dirname(__FILE__) + '/../')
#Dir[File.join(File.dirname(__FILE__)+'/../')+'**/*.rb'].each{|x| require x}
$VERBOSE=nil


Spec::Runner.configure do |config|
  config.mock_with :mocha
end

# TEST_FEDORA_URL = 'http://fedoraAdmin:fedoraAdmin@127.0.0.1:8080/fedora' 
# TEST_SOLR_URL = 'http://127.0.0.1:8080/solr' 
# Fedora::Repository.register(TEST_FEDORA_URL)
# ActiveFedora::SolrService.register(TEST_SOLR_URL)

def fixture(file)
  File.new(File.join(File.dirname(__FILE__), 'fixtures', file))
end