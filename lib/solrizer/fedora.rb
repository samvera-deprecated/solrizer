require "solrizer"
module Solrizer::Fedora
end
Dir[File.join(File.dirname(__FILE__),"fedora","*.rb")].each {|file| require file }

Solrizer::Extractor.send(:include, Solrizer::Fedora::Extractor)