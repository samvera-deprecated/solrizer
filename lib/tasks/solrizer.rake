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
    readme_filename = 'README.textile'
    textile_docs = []
    Dir[File.join(project_root, "*.textile")].each_with_index do |f, index| 
      unless f.include?("/#{readme_filename}") # Skip readme, which is already built by the --readme option
        textile_docs << '-'
        textile_docs << f
      end
    end
    yt.files   = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) + textile_docs
    yt.options = ['--output-dir', doc_destination, '--readme', readme_filename]
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
