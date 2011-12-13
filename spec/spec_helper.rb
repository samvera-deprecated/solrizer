require 'rubygems'
require 'rspec'
require 'solrizer'

RSpec.configure do |config|
  config.mock_with :mocha
end

def fixture(file)
  File.new(File.join(File.dirname(__FILE__), 'fixtures', file))
end
