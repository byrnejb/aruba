When /^I do aruba (.*) step$/ do |aruba_step|
  begin
    When(aruba_step)
  rescue => e
    @aruba_exception = e
  end
end

Then /^the output should contain the JRuby version$/ do
  Then %{the output should contain "#{JRUBY_VERSION}"}
end

Then /^the output should contain the current Ruby version$/ do
  Then %{the output should contain "#{RUBY_VERSION}"}
end

Then /^aruba should fail with "([^"]*)"$/ do |error_message|
  @aruba_exception.message.should =~ compile_and_escape(error_message)
end
