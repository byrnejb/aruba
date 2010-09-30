require 'pathname'
lib_path = Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/'
require lib_path + 'aruba/cucumber_steps'
