lib_path = Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/'
require lib_path + 'aruba/cucumber'
require lib_path + 'aruba/aruba_extension_steps'
