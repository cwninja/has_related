require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"

task :default => :test

require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

spec = Gem::Specification.new do |s|
  s.name              = "has_related"
  s.version           = "0.1.0"
  s.summary           = "Finds similar items based on user demand."
  s.author            = "Tom Lea"
  s.email             = "contrib@tomlea.co.uk"
  s.homepage          = "http://tomlea.co.uk"

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(README.markdown)
  s.rdoc_options      = %w(--main README.markdown)

  s.files             = %w(README.markdown) + Dir.glob("{test,lib,rails}/**/*")
  s.require_paths     = ["lib"]

  s.rubyforge_project = "has_related"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

Rake::RDocTask.new do |rd|
  rd.main = "README.markdown"
  rd.rdoc_files.include("README.markdown", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end
