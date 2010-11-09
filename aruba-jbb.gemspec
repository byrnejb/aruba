# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aruba-jbb}
  s.version = "0.2.6.13"
  s.authors = ["Aslak Hellesøy", "David Chelimsky", "James B. Byrne", "Mike Sassak"]
  s.date = %q{2010-11-09}
  s.description = %q{Fork of Aruba, Cucumber steps for testing CLI applications.}
  s.email = %q{cukes@googlegroups.com}
  s.homepage = %q{http://github.com/byrnejb/aruba}
  s.rdoc_options = ["--charset=UTF-8"]
  s.summary = %q{Cucumber steps for testing external processes from the CLI}

  s.add_dependency 'cucumber', '~> 0.9.3'
  s.add_dependency 'background_process' # Can't specify a version - bundler/rubygems chokes on '2.1'
  s.add_development_dependency 'rspec', '~> 2.0.1'

  s.rubygems_version   = "1.3.7"
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ["LICENSE", "README.rdoc", "History.txt"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
