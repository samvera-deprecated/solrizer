# This module is only suitable to mix into Classes that use the OM::XML::Document Module
module Solrizer::XML::TerminologyBasedSolrizer
  def self.included(klass)
    klass.send(:include, Solrizer::Common)
    klass.send(:extend, ClassMethods)
  end
  
  # Module Methods
  module ClassMethods
  
    # Build a solr document from +doc+ based on its terminology
    # @param [OM::XML::Document] doc  
    # @param [Hash] (optional) solr_doc (values hash) to populate
    def solrize(doc, solr_doc=Hash.new, field_mapper = nil)
      unless doc.class.terminology.nil?
        doc.class.terminology.terms.each_pair do |term_name,term|
          doc.solrize_term(term, solr_doc, field_mapper)
        end
      end

      return solr_doc
    end
    
    # Populate a solr document with fields based on nodes in +xml+ 
    # Values for a term are gathered by to +term_pointer+ using OM::XML::TermValueOperators.term_values 
    # and are deserialized by OM according to :type, as determined in its terminology.
    # The content of the actual field in solr is each +node+ of the +nodeset+ returned by OM,
    # rendered to a string.
    # @param [OM::XML::Document] doc xml document to extract values from
    # @param [OM::XML::Term] term corresponding to desired xml values
    # @param [Hash] (optional) solr_doc (values hash) to populate
    def solrize_term(doc, term, solr_doc = Hash.new, field_mapper = nil, opts={})
      parents = opts.fetch(:parents, [])
      term_pointer = parents+[term.name]
      nodeset = doc.term_values(*term_pointer)
      
      nodeset.each do |n|
        doc.solrize_node(n, term_pointer, term, solr_doc, field_mapper)
        unless term.kind_of? OM::XML::NamedTermProxy
          term.children.each_pair do |child_term_name, child_term|
            doc.solrize_term(child_term, solr_doc, field_mapper, opts={:parents=>parents+[{term.name=>nodeset.index(n)}]})
          end
        end
      end
      solr_doc
    end

    # Populate a solr document with solr fields corresponding to the given xml node
    # Field names are generated using settings from the term in the +doc+'s terminology corresponding to +term_pointer+
    # If the supplied term does not have an index_as attribute, no indexing will be performed.
    # @param [Nokogiri::XML::Node] node to solrize
    # @param [OM::XML::Document] doc document the node came from
    # @param [Array] term_pointer Array pointing to the term that should be used for solrization settings
    # @param [Term] term the term to be solrized
    # @param [Hash] (optional) solr_doc (values hash) to populate
    # @return [Hash] the solr doc
    def solrize_node(node_value, doc, term_pointer, term, solr_doc = Hash.new, field_mapper = nil, opts = {})
      return solr_doc unless term.index_as && !term.index_as.empty?
      
      generic_field_name_base = OM::XML::Terminology.term_generic_name(*term_pointer)
      create_and_insert_terms(generic_field_name_base, node_value, term.index_as, solr_doc)
      
      if term_pointer.length > 1
        hierarchical_field_name_base = OM::XML::Terminology.term_hierarchical_name(*term_pointer)
        create_and_insert_terms(hierarchical_field_name_base, node_value, term.index_as, solr_doc)
      end
      solr_doc
    end

  end

  
  # Instance Methods
  
  attr_accessor :field_mapper
  
  def to_solr(solr_doc = Hash.new, field_mapper = self.field_mapper) # :nodoc:
    self.class.solrize(self, solr_doc, field_mapper)
  end
  
  def solrize_term(term, solr_doc = Hash.new, field_mapper = self.field_mapper, opts={})
    self.class.solrize_term(self, term, solr_doc, field_mapper, opts)    
  end
  
  def solrize_node(node, term_pointer, term, solr_doc = Hash.new, field_mapper = self.field_mapper, opts={})
    self.class.solrize_node(node, self, term_pointer, term, solr_doc, field_mapper, opts)
  end
  
end
