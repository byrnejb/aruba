# -*- encoding: utf-8 -*-
require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.version = "0.2.1"
    gem.name = "aruba-jbb"
    gem.summary = %Q{CLI Steps for Cucumber}
    gem.description = %Q{CLI Steps for Cucumber, hand-crafted for you in Aruba}
    gem.email = "cukes@googlegroups.com"
    gem.homepage = "http://github.com/byrnejb/aruba"
    gem.authors = ["Aslak Hellesøy", "David Chelimsky", "James B. Byrne"]
    gem.add_development_dependency "rspec", ">= 1.3.0"
    gem.add_development_dependency "cucumber", ">= 0.8.3"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) is not available. \n" +
         "  Install it with: gem install jeweler"
end

begin
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = %w{--tags ~@jruby} unless defined?(JRUBY_VERSION)
    t.rcov = false
  end

  task :cucumber => :check_dependencies
rescue LoadError
  task :cucumber do
    abort "Cucumber is not available. \n" + 
            "  In order to run features, you must install it. \n" +
            "  gem install cucumber"
  end
end

task :default => :cucumber

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "aruba-jbb #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/aruba/cucumber_steps.rb')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
