Feature: run command should not limit size of STDOUT

  In order to specify commands that produce output to STDOUT
  As a developer using Cucumber
  I want all output in STDOUT to display  

  @wip @announce
  Scenario: Handle a large STDOUT data stream
    #When I run "ruby -e \" 500.times.each { |i| puts %Q(rword #{i+1} ) * 6 }\""
    #When I run "ruby -e \" 1000.times { puts %Q(rword ) * 12 }\""
    #Then the stdout should contain "rword"
    When I run "ruby -e 'puts :a.to_s * 65535'"
    Then the stdout should contain "aaaaa"
    When I run "ruby -e 'puts :b.to_s * 65536'"
    Then the stdout should contain "bbbbb"
    When I run "ruby -e 'puts :c.to_s * 65537'"
    Then the stdout should contain "ccccc"
