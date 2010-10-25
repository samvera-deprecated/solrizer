require 'rubygems'
module Solrizer;end

Dir[File.join(File.dirname(__FILE__),"solrizer","*.rb")].each {|file| require file }