Feature: run command should not limit size of STDOUT

  In order to specify commands that produce output to STDOUT
  As a developer using Cucumber
  I want all output in STDOUT to display  

  @wip @announce
  Scenario: Handle a large STDOUT data stream
    #When I run "ruby -e \" 500.times.each { |i| puts %Q(rword #{i+1} ) * 6 }\""
    When I run "ruby -e \" 1500.times { puts %Q(rword ) * 12 }\""
    Then the stdout should contain "rword"

  Scenario: Tons of output
    When I run "ruby -e 'puts :a.to_s * 65536'"
    Then the output should contain "a"
    And the output should be 65537 bytes long

  Scenario: Tons of interactive output
    When I run "ruby -e 'len = gets.chomp; puts :a.to_s * len.to_i'" interactively
    And I type "65536"
    Then the output should contain "a"
    And the output should be 65536 bytes long

