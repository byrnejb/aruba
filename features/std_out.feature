Feature: run command should not limit size of STDOUT

  In order to specify commands that produce output to STDOUT
  As a developer using Cucumber
  I want all output in STDOUT to display  

  @wip @announce
  Scenario: Handle a large STDOUT data stream
    #When I run "ruby -e \" 500.times.each { |i| puts %Q(rword #{i+1} ) * 6 }\""
    When I run "ruby -e \" 1000.times { puts %Q(rword ) * 12 }\""
    Then the stdout should contain "rword"
