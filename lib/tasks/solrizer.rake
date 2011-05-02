desc "Task to execute builds on a Hudson Continuous Integration Server."
task :hudson do
  Rake::Task["doc"].invoke
  Rake::Task["solrizer:rspec"].invoke
end

# Use yard to build docs
begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  project_root = File.expand_path("#{File.dirname(__FILE__)}/../../")
  doc_destination = File.join(project_root, 'doc')

  YARD::Rake::YardocTask.new(:doc) do |yt|
    yt.files   = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) + 
                 [ File.join(project_root, 'README.textile') ]
    yt.options = ['--output-dir', doc_destination, '--readme', 'README.textile']
  end
rescue LoadError
  desc "Generate YARD Documentation"
  task :doc do
    abort "Please install the YARD gem to generate rdoc."
  end
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
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines("spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end

end
