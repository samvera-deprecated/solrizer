require 'solrizer'
require 'benchmark'

n = 500_000
Benchmark.bm do |x|
  x.report do
    n.times do
      Solrizer.solr_name('foo', :stored_searchable)
    end 
  end
end
