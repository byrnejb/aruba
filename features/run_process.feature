Feature: run command should only access libraries loaded by itself

  In order to ensure that programs load all required libraries
  As a developer using Cucumber
  I want a process to fail if any lubraries are absent


  Scenario: Missing libraries cause an error
    When I run "ruby -e 'File.makedirs( \"tmp/fail\" )'" with errors
    Then stderr should contain "undefined method `makedirs'"

