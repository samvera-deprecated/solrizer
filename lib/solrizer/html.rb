require "solrizer"
module Solrizer::HTML
end

Dir[File.join(File.dirname(__FILE__),"html","*.rb")].each {|file| require file }

Solrizer::Extractor.send(:include, Solrizer::HTML::Extractor)