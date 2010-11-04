@timeout
Feature: process should timeout

  In order to prevent test runs from suspending indefinitiely
  As a developer using Cucumber Aruba
  I want long processes to terminate after a fixed elapsed time

  
  Scenario: process runner times out for long process
    When I run "ruby -e 'sleep(21)'"
    Then the exit status should not be 0
      And stderr should contain "execution expired"

  
  Scenario: process runner timeout can be set lower than default
    Given the following step should fail with RuntimeError:
      """
      When I run "ruby -e 'sleep(2)'" with timeout of "1.5" seconds
      """
    Then the exit status should be -1 

  
  Scenario: process runner timeout can be set higher than default
    When I run "ruby -e 'sleep(21)'" with timeout of "22" seconds
    Then the exit status should be 0
      And stderr should be empty
      And stderr should not contain "execution expired"

  @announce
  Scenario: environment variable controls timeout value
    Given I set the env variable "ARUBA_RUN_TIMEOUT" to "25" seconds
    When I run "ruby -e 'sleep(21)'" 
    Then the exit status should be 0
    When I set the env variable "ARUBA_RUN_TIMEOUT" to "5" seconds
      And I run "ruby -e 'sleep(10)'"
    Then the exit status should be -1
      And stderr should contain "Aruba::Api::ProcessTimeout: execution expired"
