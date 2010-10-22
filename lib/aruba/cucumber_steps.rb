require 'aruba/api'

World(Aruba::Api)


Before do 
  aruba_working_dir_init
end


Before('@aruba-tmpdir') do
  aruba_working_dir_init
end


Before('@no-aruba-tmpdir') do
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


When /display stderr/ do
  announce_or_puts(last_stderr)
end


When /display stdout/ do
  announce_or_puts(last_stdout)
end


When /do(?:es)? have (?:a|the) directory named "([^\"]*)"$/ do |dir_name|
  create_dir(dir_name)
end


When /do(?:es)? have (?:a|the) file named "([^\"]*)" (?:containing|with):$/ \
  do |file_name, file_content|
  create_file(file_name, file_content)
end


When /do(?:es)? have an empty file named "([^\"]*)"$/ do |file_name|
  create_file(file_name, "")
end


When /exit status should be (-?\d+)$/ do |exit_status|
  @last_exit_status.should == exit_status.to_i
end


When /exit status should not be (-?\d+)$/ do |exit_status|
  @last_exit_status.should_not == nil
  @last_exit_status.should_not == exit_status.to_i
end


When /file "([^\"]*)" should contain "([^\"]*)"$/ do |file, partial_content|
  check_file_content(file, partial_content, true)
end


When /file "([^\"]*)" should contain:$/ do |file, partial_content|
  check_file_content(file, partial_content, true)
end


When /file "([^\"]*)" should not contain "([^\"]*)"$/ do |file, partial_content|
  check_file_content(file, partial_content, false)
end


When /file "([^\"]*)" should not contain:$/ do |file, partial_content|
  check_file_content(file, partial_content, false)
end


When /file "([^\"]*)" should not match \/([^\/]*)\/$/ do |file, partial_content|
  check_file_content(file, /#{partial_content}/, false)
end


When /file "([^\"]*)" should match \/([^\/]*)\/$/ do |file, partial_content|
  check_file_content(file, /#{partial_content}/, true)
end


When /following directories should exist:$/ do |directories|
  check_directory_presence(directories.raw.map{
    |directory_row| directory_row[0]}, true)
end


When /following directories should not exist:$/ do |directories|
  check_directory_presence(directories.raw.map{
    |directory_row| directory_row[0]}, false)
end


When /following files? should exist:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, true)
end


When /following files? should not exist:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, false)
end


When /output should contain "([^\"]*)"$/ do |partial_output|
  combined_output.should =~ regexp(partial_output)
end


When /output should not contain "([^\"]*)"$/ do |partial_output|
  combined_output.should_not =~ regexp(partial_output)
end


When /output should contain:$/ do |partial_output|
  combined_output.should =~ regexp(partial_output)
end


When /output should not contain:$/ do |partial_output|
  combined_output.should_not =~ regexp(partial_output)
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


When /rebase the directory "()"$/ do |dir|
  rebase(dir.to_a)
end


When /rebase the directory named "([^\"]*)"$/ do |dir|
  rebase(dir)
end


When /run "(.*)"$/ do |cmd|
  run(unescape(cmd), false)
end


When /run "(.*)" interactively$/ do |cmd|
  run_interactive(unescape(cmd))
end


When /run "(.*)" with errors?$/ do |cmd|
  run(unescape(cmd), false)
end


When /run "(.*)" with timeout of "(\d+\.?\d*)" seconds$/ do |cmd, time|
  run(unescape(cmd), true, time.to_f)
end


When /run "(.*)" without errors?$/ do |cmd|
  run(unescape(cmd), true)
end


When /should (pass|fail) with:$/ do |pass_fail, partial_output|
  When "output should contain:", partial_output
  if pass_fail == 'pass'
    @last_exit_status.should == 0
  else
    @last_exit_status.should_not == 0
  end
end


When /should (pass|fail) with regexp?:$/ do |pass_fail, partial_output|
  Then "the output should match:", partial_output
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
  @last_stderr.should =~ regexp(partial_output)
end


When /stdout should contain "([^\"]*)"$/ do |partial_output|
  @last_stdout.should =~ regexp(partial_output)
end


When /stderr should not contain "([^\"]*)"$/ do |partial_output|
  @last_stderr.should_not =~ regexp(partial_output)
end


When /stdout should not contain "([^\"]*)"$/ do |partial_output|
  @last_stdout.should_not =~ regexp(partial_output)
end


When /type "([^\"]*)"$/ do |input|
  write_interactive(ensure_newline(input))
end


When /(?:use|using) a clean gemset "([^\"]*)"$/ do |gemset|
  use_clean_gemset(gemset)
end
