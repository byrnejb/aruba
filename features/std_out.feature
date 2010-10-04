Feature: run command should not limit size of STDOUT

  In order to specify commands that produce output to STDOUT
  As a developer using Cucumber
  I want all output in STDOUT to display


  Scenario:
    Then clean up the working directory  Scenario: create a dir
    Given a directory named "foo/bar"
    When I run "ruby -e \" 500.times { puts %Q(rword )* 30 }\""
    Then the stdout should contain "rword"
