require "xmlsimple"

module Solrizer::XML::Extractor

  #
  # This method extracts solr fields from simple xml
  # If you want to do anything more nuanced with the xml, use OM instead.
  #
  # @param [xml] text xml content to index
  # @param [Hash] solr_doc
  def xml_to_solr( text, solr_doc=Hash.new, mapper = Solrizer.default_field_mapper )
    doc = XmlSimple.xml_in( text )
    
    doc.each_pair do |name, value|
      if value.kind_of?(Array) 
        if value.first.kind_of?(Hash)
          # This deals with the way xml-simple handles nodes with attributes
          solr_doc.merge!({mapper.solr_name(name, :stored_searchable, :type=>:text).to_sym => "#{value.first["content"]}"})
        elsif value.length > 1
          solr_doc.merge!({mapper.solr_name(name, :stored_searchable, :type=>:text).to_sym => value})
        else
          solr_doc.merge!({mapper.solr_name(name, :stored_searchable, :type=>:text).to_sym => "#{value.first}"})
        end
      else
        solr_doc.merge!({mapper.solr_name(name, :stored_searchable, :type=>:text).to_sym => "#{value}"})
      end
    end

    return solr_doc
  end
  
end
