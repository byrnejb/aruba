Before('@rebase-test') do
  @rebase_test_dir = 'testdata'
  @soft_link_target = File.join(current_dir.to_s, @rebase_test_dir)
  # puts @soft_link_target
  FileUtils.rm_rf(@rebase_test_dir)
  FileUtils.mkdir_p(@rebase_test_dir)
  rebase(@rebase_test_dir)
  #File.open("delete_me.txt", 'w') { |f| f << "" }
end


After('@rebase-test') do
  FileUtils.rm_rf(@rebase_test_dir)
end


When /create the cwd sub-directory named "([^\"]*)"/ do |dir|
  FileUtils.mkdir_p(dir)
end


When /delete the cwd sub-directory named "([^\"]*)"/ do |dir|
  FileUtils.rm_rf(dir)
end


When /^"([^\"]*)" should have a soft link in the aruba working directory$/ do \
  |dir|
  link = File.join(current_dir.to_s, dir)
  File.symlink?(link).should be_true
end


When /the rebase-test before block conditions/ do
  # Do nothing
end


When /soft links should exist in the aruba working directory/ do
  File.symlink?(@soft_link_target).should be_true
end


When /do aruba (.*) step$/ do |aruba_step|
  begin
    When(aruba_step)
  rescue => e
    @aruba_exception = e
  end
end


When /the clean_up api method should fail/ do
  begin
    clean_up
    fail("clean_up api method did not raise error and should have")
  rescue => @last_stderr
  end
end


When /^the output should contain the JRuby version$/ do
  Then %{the output should contain "#{JRUBY_VERSION}"}
end


When /^the output should contain the current Ruby version$/ do
  Then %{the output should contain "#{RUBY_VERSION}"}
end

  
When /^aruba should fail with "([^\"]*)"$/ do |error_message|
  @aruba_exception.message.should =~ regexp(error_message)
end


When /^the following step should fail with RuntimeError:$/ do |multiline_step|
  proc {steps multiline_step}.should raise_error(RuntimeError)
end


When /^the following step should fail with Spec::Expectations::ExpectationNotMetError:$/ do |multiline_step|
  proc {steps multiline_step}.should raise_error(RSpec::Expectations::ExpectationNotMetError)
end

Then /^the output should be at least "(\d+)" bytes long$/ do |length|
  combined_output.length.should >= length.to_i 
end

Then /^the output should be exactly "(\d+)" bytes long$/ do |length|
  combined_output.length.should == length.to_i 
end
