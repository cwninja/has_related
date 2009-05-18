# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{has_related}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Lea"]
  s.date = %q{2009-05-18}
  s.email = %q{contrib@tomlea.co.uk}
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["README.markdown", "test/dataset_generation_test.rb", "test/test_helper.rb", "lib/has_related.rb", "rails/init.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://tomlea.co.uk}
  s.rdoc_options = ["--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{has_related}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Finds similar items based on user demand.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
