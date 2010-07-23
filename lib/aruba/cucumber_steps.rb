require 'aruba/api'

World(Aruba::Api)


Before do 
  aruba_working_dir_init
end


Before('@aruba-tmpdir') do
  aruba_working_dir_init
end


Before('@no-aruba-tmpdir') do
  puts aruba_working_dir
  aruba_working_dir_set('./')
  dirs_init
end


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


When /append to "([^\"]*)" with:$/ do |file_name, file_content|
  append_to_file(file_name, file_content)
end


When /cd to "([^\"]*)"$/ do |dir|
  cd(dir)
end


When /clean up the working directory/ do
  clean_up
end


When /do have a directory named "([^\"]*)"$/ do |dir_name|
  create_dir(dir_name)
end


When /do have a file named "([^\"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end


When /do have an empty file named "([^\"]*)"$/ do |file_name|
  create_file(file_name, "")
end


When /using rvm "([^\"]*)"$/ do |rvm_ruby_version|
  use_rvm(rvm_ruby_version)
end


When /using( an empty)? rvm gemset "([^\"]*)"$/ do |empty_gemset, rvm_gemset|
  use_rvm_gemset(rvm_gemset, empty_gemset)
end


When /using rvm gemset "([^\"]*)" with Gemfile:$/ do |rvm_gemset, gemfile|
  use_rvm_gemset(rvm_gemset, true)
  install_gems(gemfile)
end


When /rebase the directory named "([^\"]*)"$/ do |dir|
  rebase(dir)
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


When /output should contain "([^\"]*)"$/ do |partial_output|
  combined_output.should =~ compile_and_escape(partial_output)
end


When /output should not contain "([^\"]*)"$/ do |partial_output|
  combined_output.should_not =~ compile_and_escape(partial_output)
end


When /output should contain:$/ do |partial_output|
  combined_output.should =~ compile_and_escape(partial_output)
end


When /output should not contain:$/ do |partial_output|
  combined_output.should_not =~ compile_and_escape(partial_output)
end


When /output should contain exactly "([^\"]*)"$/ do |exact_output|
  combined_output.should == unescape(exact_output)
end


When /output should contain exactly:$/ do |exact_output|
  combined_output.should == exact_output
end


# "the output should match" allows regex in the partial_output, if
# you don't need regex, use "the output should contain" instead since
# that way, you don't have to escape regex characters that
# appear naturally in the output
When /output should match \/([^\/]*)\/$/ do |partial_output|
  combined_output.should =~ /#{partial_output}/
end


When /output should match:$/ do |partial_output|
  combined_output.should =~ /#{partial_output}/m
end


When /exit status should be (\d+)$/ do |exit_status|
  @last_exit_status.should == exit_status.to_i
end


When /exit status should not be (\d+)$/ do |exit_status|
  @last_exit_status.should_not == exit_status.to_i
end


When /rebase the directory "()"$/ do |dir|
  rebase(dir.to_a)
end


When /should (pass|fail) with:$/ do |pass_fail, partial_output|
  When "output should contain:", partial_output
  if pass_fail == 'pass'
    @last_exit_status.should == 0
  else
    @last_exit_status.should_not == 0
  end
end


When /stderr should be empty$/ do
  @last_stderr.should == ""
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


When /following files? should exist:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, true)
end


When /following files? should not exist:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, false)
end


When /following directories? should exist:$/ do |directories|
  check_directory_presence(directories.raw.map{
    |directory_row| directory_row[0]}, true)
end


When /following directories? should not exist:$/ do |directories|
  check_file_presence(directories.raw.map{
    |directory_row| directory_row[0]}, false)
end


When /file "([^\"]*)" should contain "([^\"]*)"$/ do |file, partial_content|
  check_file_content(file, partial_content, true)
end


When /file "([^\"]*)" should not contain "([^\"]*)"$/ do |file, partial_content|
  check_file_content(file, partial_content, false)
end
