require "pathname"
lib_path = Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/'
unless ENV['NO_ARUBA_STEPS']
  require lib_path + 'aruba/cucumber_steps'
end
