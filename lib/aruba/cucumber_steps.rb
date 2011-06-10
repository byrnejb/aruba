require 'aruba/api'

World(Aruba::Api)

Before('@disable-bundler') do
  unset_bundler_env_vars
end

Before do
  @__aruba_original_paths = (ENV['PATH'] || '').split(File::PATH_SEPARATOR)
    ENV['PATH'] = ([File.expand_path('bin')] + 
      @__aruba_original_paths).join(File::PATH_SEPARATOR)
end

After do
  ENV['PATH'] = @__aruba_original_paths.join(File::PATH_SEPARATOR)
end


Before do
  #FileUtils.rm_rf(current_dir)
end


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


Before('@announce-dir') do
  @announce_dir = true
end


Before('@announce-env') do
  @announce_env = true
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
  @announce_env = true
  @announce_dir = true
  @announce_cmd = true
end


Before('@puts') do
  @puts = true
end


After do
  restore_env
end


When /(?:add|set) the env(?:ironment)? variable "([^\"]*)" to "(.*)"/ \
  do |var, val|
  set_env(var, val)
end


When /appends? to "([^\"]*)" with:$/ do |file_name, file_content|
  append_to_file(file_name, file_content)
end


When /(?:cds?|chdirs?) to "([^\"]*)"$/ do |dir|
  cd(dir)
end


When /clean up the working directory/ do
  clean_up
end


When /display stderr/ do
  announce_or_puts(last_stderr)
end


When /(?:delete|unset) the env(?:ironment)? variable "([^\"]*)"$/ do |var|
  remove_env(var)
end


When /display stdout/ do
  announce_or_puts( last_stdout )
end


When /using a clean gemset "([^\"]*)"$/ do |gemset|
  use_clean_gemset( gemset )
end


When /do(?:es)? have (?:a|the) directory named "([^\"]*)"$/ do |dir_name|
  create_dir( dir_name )
end


When /do(?:es)? have (?:a|the) file named "([^\"]*)"$/ do |file_name|
  create_file( file_name, "" )
end


When /do(?:es)? have (?:a|the) file named "([^\"]*)" (?:containing|with):$/ \
  do |file_name, file_content|
  create_file( file_name, file_content )
end


When /do(?:es)? have an empty file named "([^\"]*)"$/ do |file_name|
  create_file( file_name, "" )
end


When /exit status should be (-?\d+)$/ do |exit_status|
  @last_exit_status.should == exit_status.to_i
end


When /exit status should not be (-?\d+)$/ do |exit_status|
  @last_exit_status.should_not == nil
  @last_exit_status.should_not == exit_status.to_i
end


When /file (?:named )?"([^\"]*)" should contain "([^\"]*)"$/\
  do |file, partial_content|
  check_file_content(file, partial_content, true)
end


When /file (?:named )?"([^\"]*)" should contain:$/\
  do |file, partial_content|
  check_file_content(file, partial_content, true)
end


When /file (?:named )?"([^\"]*)" should not contain "([^\"]*)"$/\
  do |file, partial_content|
  check_file_content(file, partial_content, false)
end


When /file (?:named )?"([^\"]*)" should not contain:$/\
  do |file, partial_content|
  check_file_content(file, partial_content, false)
end


When /file (?:named )?"([^\"]*)" should exist$/ do |file|
  check_file_presence([file_name], true)
end


When /file (?:named )?"([^\"]*)" should not exist$/ do |file|
  check_file_presence([file], false)
end


When /file (?:named )?"([^\"]*)" should not match \/([^\/]*)\/$/\
  do |file, partial_content|
  check_file_content(file, /#{partial_content}/, false)
end


When /file (?:named )?"([^\"]*)" should match \/([^\/]*)\/$/\
  do |file, partial_content|
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
  assert_partial_output(partial_output)
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


When /overwrites? "([^\"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content, true)
end


When /rebase the directory "()"$/ do |dir|
  rebase(dir.to_a)
end


When /rebase the directory named "([^\"]*)"$/ do |dir|
  rebase(dir)
end


When /removes? the file "([^\"]*)"$/ do |file_name|
  remove_file(file_name)
end


When /runs? "(.*)"$/ do |cmd|
  run(unescape(cmd), false)
end


When /runs? "(.*)" with(out)? errors?(?:(?: and)?(?: with)? timeout of "(\d+\.?\d*)" seconds?)?$/\
  do |cmd, yn, time|
  expected = !!yn
  run(unescape(cmd), expected, time)
end


When /runs? "([^\"]*)" interactively$/ do |cmd|
  run_interactive(unescape(cmd))
end


When /(?:successfully )?runs? "(.*)" with timeout of "(\d+\.?\d*)" seconds??$/\
  do |cmd, time|
  run(unescape(cmd), true, time)
end


When /should (pass|fail) with:$/ do |pass_fail, partial_output|
  assert_exit_status_and_output(pass_fail == "pass", partial_output, false)
end


Then /should (pass|fail) with exactly:$/ do |pass_fail, exact_output|
  assert_exit_status_and_output(pass_fail == "pass", exact_output, true)
end


When /should (pass|fail) with regexp?:$/ do |pass_fail, partial_output|
  When "output should match:", partial_output
  if pass_fail == 'pass'
    @last_exit_status.should == 0
  else
    @last_exit_status.should_not == 0
  end
end


When /stderr should be empty$/ do
  @last_stderr.should == ""
end


When /stdout should be empty$/ do
  @last_stdout.should == ""
end


When /stderr should not be empty$/ do
  @last_stderr.should_not == ""
end


When /stdout should not be empty$/ do
  @last_stdout.should_not == ""
end


When /stderr should contain "([^\"]*)"$/ do |partial_output|
  @last_stderr.should =~ regexp(partial_output)
end


When /stdout should contain "([^\"]*)"$/ do |partial_output|
  @last_stdout.should =~ regexp(partial_output)
end


Then /stderr should contain exactly:$/ do |exact_output|
  @last_stderr.should == exact_output
end


Then /stdout should contain exactly:$/ do |exact_output|
  @last_stdout.should == exact_output
end


When /stderr should not contain "([^\"]*)"$/ do |partial_output|
  @last_stderr.should_not =~ regexp(partial_output)
end


When /stdout should not contain "([^\"]*)"$/ do |partial_output|
  @last_stdout.should_not =~ regexp(partial_output)
end


When /(?:inputs?|types? in) "([^\"]*)"$/ do |input|
  write_interactive(ensure_newline(input))
end


When /(?:use|using) a clean gemset "([^\"]*)"$/ do |gemset|
  use_clean_gemset(gemset)
end
  

When /writes? to "([^\"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content, false)
end
