module Samples
  class ModsArticle
    
    include OM::XML::Document
    
    set_terminology do |t|
      t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd", "xmlns:foo"=>"http://my.custom.namespace")


      t.title_info(:path=>"titleInfo") {
        t.main_title(:index_as=>[:facetable],:path=>"title", :label=>"title") {
          t.main_title_lang(:path=>{:attribute=> "xml:lang"})
        }
        t.french_title(:ref=>[:title_info,:main_title], :attributes=>{"xml:lang"=>"fre"})
        
        t.language(:index_as=>[:facetable, :stored_searchable],:path=>{:attribute=>"lang"})
      } 
      t.language{
        t.lang_code(:index_as=>[:facetable], :path=>"languageTerm", :attributes=>{:type=>"code"})
      }
      t.abstract(:index_as=>[:stored_searchable])
      t.subject {
        t.topic(:index_as=>[:facetable])
      }      
      t.topic_tag(:proxy=>[:subject, :topic], :index_as=>[:stored_searchable])    
      # t.topic_tag(:index_as=>[:facetable],:path=>"subject", :default_content_path=>"topic")
      # This is a mods:name.  The underscore is purely to avoid namespace conflicts.
      t.name_ {
        # this is a namepart
        t.namePart(:type=>:string, :label=>"generic name")
        # affiliations are great
        t.affiliation
        t.institution(:path=>"affiliation", :index_as=>[:facetable], :label=>"organization")
        t.displayForm
        t.role(:ref=>[:role])
        t.description(:index_as=>[:facetable])
        t.date(:path=>"namePart", :attributes=>{:type=>"date"})
        t.last_name(:path=>"namePart", :attributes=>{:type=>"family"}, :index_as=>[:stored_searchable])
        t.first_name(:path=>"namePart", :attributes=>{:type=>"given"}, :label=>"first name")
        t.terms_of_address(:path=>"namePart", :attributes=>{:type=>"termsOfAddress"})
        t.computing_id
        t.name_content(:path=>"text()")
      }
      # lookup :person, :first_name        
      t.person(:ref=>:name, :attributes=>{:type=>"personal"}, :index_as=>[:facetable])
      t.department(:proxy=>[:person,:description],:index_as=>[:facetable])
      t.organization(:ref=>:name, :attributes=>{:type=>"corporate"}, :index_as=>[:facetable])
      t.conference(:ref=>:name, :attributes=>{:type=>"conference"}, :index_as=>[:facetable])
      t.role {
        t.text(:path=>"roleTerm",:attributes=>{:type=>"text"}, :index_as=>[:stored_searchable])
        t.code(:path=>"roleTerm",:attributes=>{:type=>"code"})
      }
      t.journal(:path=>'relatedItem', :attributes=>{:type=>"host"}) {
        t.title_info(:index_as=>[:facetable],:ref=>[:title_info])
        t.origin_info(:path=>"originInfo") {
          t.publisher
          t.date_issued(:path=>"dateIssued", :type => :date, :index_as => [:stored_searchable])
          t.issuance(:index_as=>[:facetable])
        }
        t.issn(:path=>"identifier", :attributes=>{:type=>"issn"})
        t.issue(:path=>"part") {
          t.volume(:path=>"detail", :attributes=>{:type=>"volume"}, :default_content_path=>"number")
          t.level(:path=>"detail", :attributes=>{:type=>"number"}, :default_content_path=>"number")
          t.extent
          t.pages(:path=>"extent", :attributes=>{:unit=>"pages"}) {
            t.start
            t.end
          }
          t.start_page(:proxy=>[:pages, :start])
          t.end_page(:proxy=>[:pages, :end])
          t.publication_date(:path=>"date", :type => :date, :index_as => [:stored_searchable])
        }
      }
      t.note
      t.location(:path=>"location") {
        t.url(:path=>"url")
      }
      t.publication_url(:proxy=>[:location,:url])
      t.title(:proxy=>[:title_info, :main_title])
      t.journal_title(:proxy=>[:journal, :title_info, :main_title])
      t.pub_date(:proxy=>[:journal, :issue, :publication_date])
      t.issue_date(:ref=>[:journal, :origin_info, :date_issued], :type=> :date)
    end
    
    # Changes from OM::Properties implementation
    # renamed family_name => last_name
    # start_page & end_page now accessible as [:journal, :issue, :pages, :start] (etc.)

  end
end
