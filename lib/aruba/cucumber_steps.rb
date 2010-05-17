require 'aruba/api'

World(Aruba::Api)

=begin
# Personally, I do not think that this is a very good idea.
Before do
  FileUtils.rm_rf(current_dir)
end
=end

Before('@announce-cmd') do
  @announce_cmd = true
end

Before('@announce-stdout') do
  @announce_stdout = true
end

Before('@announce-stderr') do
  @announce_stderr = true
end

Before('@announce') do
  @announce_stdout = true
  @announce_stderr = true
  @announce_cmd = true
end

#
# :section: cucumber_steps matchers
#
#
# When /am using rvm "([^\"]*)"$/ do |rvm_ruby_version|
#
# When /am using( an empty)? rvm gemset "([^\"]*)"$/ do |empty_gemset, rvm_gemset|
#
# When /am using rvm gemset "([^\"]*)" with Gemfile:$/ do |rvm_gemset, gemfile|#
#
# When /^a directory named "([^\"]*)"$/ do |dir_name|
#
# When /^a file named "([^\"]*)" with:$/ do |file_name, file_content|
#
# When /^an empty file named "([^\"]*)"$/ do |file_name|
#
# When /append to "([^\"]*)" with:$/ do |file_name, file_content|
#
# When /^I cd to "([^\"]*)"$/ do |dir|
#
# When /clean up the working directory/ do
#
# When /run "(.*)"$/ do |cmd|
#
# When /successfully run "(.*)"$/ do |cmd|
#
# When /should see "([^\"]*)" (?:in the output|on the console)$/ do |partial_output|
#
# When /should not see "([^\"]*)" (?:in the output|on the console)$/ do |partial_output|
#
# When /should see:$/ do |partial_output|
#
# When /should not see:$/ do |partial_output|
#
# When /should see exactly "([^\"]*)" (?:in the output|on the console)$/ do |exact_output|
#
# When /should see exactly:$/ do |exact_output|
#
# When /should see matching \/([^\/]*)\/ (?:in the output|on the console)$/ do |partial_output|
#
# When /should see matching:$/ do |partial_output|
#
# When /^the exit status should be (\d+)$/ do |exit_status|
#
# When /^the exit status should not be (\d+)$/ do |exit_status|
#
# When /^it should (pass|fail) with:$/ do |pass_fail, partial_output|
#
# When /^the stderr should contain "([^\"]*)"$/ do |partial_output|
#
# When /^the stdout should contain "([^\"]*)"$/ do |partial_output|
#
# When /^the stderr should not contain "([^\"]*)"$/ do |partial_output|
#
# When /^the stdout should not contain "([^\"]*)"$/ do |partial_output|
#
# When /^the following files should exist:$/ do |files|
#
# When /^the following files should not exist:$/ do |files|
#
# When /^the file "([^\"]*)" should contain "([^\"]*)"$/ do |file, partial_content|
#
# When /^the file "([^\"]*)" should not contain "([^\"]*)"$/ do |file, partial_content|
#

When /am using rvm "([^\"]*)"$/ do |rvm_ruby_version|
  use_rvm(rvm_ruby_version)
end


When /am using( an empty)? rvm gemset "([^\"]*)"$/ do |empty_gemset, rvm_gemset|
  use_rvm_gemset(rvm_gemset, empty_gemset)
end


When /am using rvm gemset "([^\"]*)" with Gemfile:$/ do |rvm_gemset, gemfile|
  use_rvm_gemset(rvm_gemset, true)
  install_gems(gemfile)
end


When /directory named "([^\"]*)"$/ do |dir_name|
  create_dir(dir_name)
end


When /file named "([^\"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end


When /empty file named "([^\"]*)"$/ do |file_name|
  create_file(file_name, "")
end


When /append to "([^\"]*)" with:$/ do |file_name, file_content|
  append_to_file(file_name, file_content)
end


When /^I cd to "([^\"]*)"$/ do |dir|
  cd(dir)
end


When /clean up the working directory/ do
  clean_up
end


When /run "(.*)"$/ do |cmd|
  run(unescape(cmd), false)
end


When /run "(.*)" with errors?$/ do |cmd|
  run(unescape(cmd), false)
end


When /run "(.*)" without errors?$/ do |cmd|
  run(unescape(cmd), true)
end


When /should see "([^\"]*)" (?:in the output|on the console)$/ do |partial_output|
  combined_output.should =~ compile_and_escape(partial_output)
end


When /should not see "([^\"]*)" (?:in the output|on the console)$/ do |partial_output|
  combined_output.should_not =~ compile_and_escape(partial_output)
end


When /should see:$/ do |partial_output|
  combined_output.should =~ compile_and_escape(partial_output)
end


When /should not see:$/ do |partial_output|
  combined_output.should_not =~ compile_and_escape(partial_output)
end


When /should see exactly "([^\"]*)" (?:in the output|on the console)$/ do |exact_output|
  combined_output.should == unescape(exact_output)
end


When /should see exactly:$/ do |exact_output|
  combined_output.should == exact_output
end


# "I should see matching" allows regex in the partial_output, if
# you don't need regex, use "I should see" instead since
# that way, you don't have to escape regex characters that
# appear naturally in the output
When /should see matching \/([^\/]*)\/ (?:in the output|on the console)$/ do |partial_output|
  combined_output.should =~ /#{partial_output}/
end


When /should see matching:$/ do |partial_output|
  combined_output.should =~ /#{partial_output}/m
end


When /exit status should be (\d+)$/ do |exit_status|
  @last_exit_status.should == exit_status.to_i
end


When /exit status should not be (\d+)$/ do |exit_status|
  @last_exit_status.should_not == exit_status.to_i
end


When /should (pass|fail) with:$/ do |pass_fail, partial_output|
  When "I should see:", partial_output
  if pass_fail == 'pass'
    @last_exit_status.should == 0
  else
    @last_exit_status.should_not == 0
  end
end


When /stderr should contain "([^\"]*)"$/ do |partial_output|
  @last_stderr.should =~ compile_and_escape(partial_output)
end


When /stdout should contain "([^\"]*)"$/ do |partial_output|
  @last_stdout.should =~ compile_and_escape(partial_output)
end


When /stderr should not contain "([^\"]*)"$/ do |partial_output|
  @last_stderr.should_not =~ compile_and_escape(partial_output)
end


When /stdout should not contain "([^\"]*)"$/ do |partial_output|
  @last_stdout.should_not =~ compile_and_escape(partial_output)
end


When /following files should exist:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, true)
end


When /following files should not exist:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, false)
end


When /file "([^\"]*)" should contain "([^\"]*)"$/ do |file, partial_content|
  check_file_content(file, partial_content, true)
end


When /file "([^\"]*)" should not contain "([^\"]*)"$/ do |file, partial_content|
  check_file_content(file, partial_content, false)
end
