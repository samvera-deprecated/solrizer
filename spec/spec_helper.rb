require 'rubygems'

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start

require 'rspec'
require 'solrizer'

RSpec.configure do |config|
end

def fixture(file)
  File.new(File.join(File.dirname(__FILE__), 'fixtures', file))
end
