require 'rubygems'
module Solrizer
  def self.version
    Solrizer::VERSION
  end
end

require "solrizer/extractor"
# Dir[File.join(File.dirname(__FILE__),"solrizer","*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__),"solrizer","*.rb")].each do |file| 
  require "solrizer/"+File.basename(file, File.extname(file)) unless file.match(/railtie.rb$/)
end

require 'solrizer/railtie' if defined?(Rails) && Rails.version >= '3.0'
