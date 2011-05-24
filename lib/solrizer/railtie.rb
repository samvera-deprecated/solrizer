require 'solrizer'
require 'rails'

module Solrizer
  class Railtie < Rails::Railtie
    initializer "solrizer.configure_rails_initialization" do
      Solrizer::FieldMapper.load_mappings
    end
  end
end
