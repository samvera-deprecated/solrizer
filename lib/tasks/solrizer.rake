desc "Task to execute builds on a Hudson Continuous Integration Server."
task :hudson do
  Rake::Task["solrizer:rspec"].invoke
end

namespace :solrizer do    
  desc 'Placeholder for generic solrization task.'
  task :solrize do
    puts "Nobody here.  Possibly you meant to run rake solrizer:fedora:solrize PID=..."
  end
  
  desc 'Placeholder for generic solrization task.'
  task :solrize_objects do
    puts "Nobody here.  Possibly you meant to run rake solrizer:fedora:solrize_objects"
  end
    
  Spec::Rake::SpecTask.new(:rspec) do |t|
#    t.spec_opts = ['--options', "/spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines("spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end
  
end
