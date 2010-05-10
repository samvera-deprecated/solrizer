$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'solrizer'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
  config.mock_with :mocha
  
  
  def fixture(file)
    File.new(File.join(File.dirname(__FILE__), 'fixtures', file))
  end
  
end
