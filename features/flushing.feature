Feature: Flushing output

  In order to test processes that output a lot of data
  As a developer using Aruba
  I want to make sure that large amounts of output aren't buffered  


  Scenario: Handle a large STDOUT data stream
    #When I run "ruby -e \" 500.times.each { |i| puts %Q(rword #{i+1} ) * 6 }\""
    When I run "ruby -e \" 1500.times { puts %Q(rword ) * 12 }\""
    Then the stdout should contain "rword"


  Scenario: Stdout should equal output length plus \n
    When I run "ruby -e 'puts :a.to_s * 65536'"
    Then the output should contain "a"
    And the output should be exactly "65537" bytes long

  
  Scenario: Interactive Stdout should equal output length plus \n
    When I run "ruby -e 'len = gets.chomp; puts :a.to_s * len.to_i'" interactively
    And I type "65536"
    Then the output should contain "a"
    And the output should be at least "65536" bytes long

