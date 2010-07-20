# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aruba}
  s.version = "0.2.2.jbb"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aslak Helles\303\270y", "David Chelimsky"]
  s.date = %q{2010-07-20}
  s.description = %q{CLI Steps for Cucumber, hand-crafted for you in Aruba}
  s.email = %q{cukes@googlegroups.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "History.txt",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "aruba.gemspec",
     "config/.gitignore",
     "features/exit_statuses.feature",
     "features/file_system_commands.feature",
     "features/output.feature",
     "features/running_ruby.feature",
     "features/step_definitions/aruba_dev_steps.rb",
     "features/support/env.rb",
     "lib/aruba.rb",
     "lib/aruba/api.rb",
     "lib/aruba/cucumber_steps.rb"
  ]
  s.homepage = %q{http://github.com/aslakhellesoy/aruba}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{CLI Steps for Cucumber}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rcov>, [">= 0.9.0"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0.beta.17"])
      s.add_development_dependency(%q<cucumber>, [">= 0.8.4"])
    else
      s.add_dependency(%q<rcov>, [">= 0.9.0"])
      s.add_dependency(%q<rspec>, [">= 2.0.0.beta.17"])
      s.add_dependency(%q<cucumber>, [">= 0.8.4"])
    end
  else
    s.add_dependency(%q<rcov>, [">= 0.9.0"])
    s.add_dependency(%q<rspec>, [">= 2.0.0.beta.17"])
    s.add_dependency(%q<cucumber>, [">= 0.8.4"])
  end
end

