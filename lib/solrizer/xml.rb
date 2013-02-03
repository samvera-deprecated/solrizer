module Solrizer::XML
end
Dir[File.join(File.dirname(__FILE__),"xml","*.rb")].each {|file| require file }

Solrizer::Extractor.send(:include, Solrizer::XML::Extractor)
