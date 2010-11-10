Feature: file system commands

  In order to specify commands that load files
  As a developer using Cucumber
  I want to create temporary files
 
  Scenario: create a dir
    Given I do have a directory named "foo/bar"
    When I run "ruby -e \"puts test ?d, 'foo'\""
    Then the stdout should contain "true"

  
  Scenario: create a file
    Given I do have a file named "bar/foo"
    When I run "ruby -e \"puts test ?f, 'bar/foo'\""
    Then the stdout should contain "true"
  
  Scenario: create a file with content
    Given I do have a file named "foo/bar/example.rb" with:
      """
      puts "hello world"
      """
    When I run "ruby foo/bar/example.rb"
    Then the output should contain "hello world"

  Scenario: append to a file
    Given I do have a file named "foo/bar/example.rb" with:
      """
      puts "hello world"
      """
    When I append to "foo/bar/example.rb" with:
      """
      puts "this was appended"
      """
    When I run "ruby foo/bar/example.rb"
    Then the output should contain "hello world"
      And the output should contain "this was appended"

  Scenario: clean up files generated in previous scenario
    When I run "ruby foo/bar/example.rb"
    Then the exit status should be 1
      And the output should contain "No such file or directory -- foo/bar/example.rb"

  Scenario: change to a subdir
    Given I do have a file named "foo/bar/example.rb" with:
      """
      puts "hello world"
      """
    When I cd to "foo/bar"
      And I run "ruby example.rb"
    Then the output should contain "hello world"

  Scenario: Reset current directory from previous scenario
    When I run "ruby example.rb"
    Then the exit status should be 1

  Scenario: Holler if cd to bad dir
    Given I do have a file named "foo/bar/example.rb" with:
      """
      puts "hello world"
      """
    When I do aruba I cd to "foo/nonexistant" step
    Then aruba should fail with "tmp/aruba/foo/nonexistant is not a directory"

  Scenario: Check for presence of a subset of files
    Given I do have an empty file named "lorem/ipsum/dolor"
      And I do have an empty file named "lorem/ipsum/sit"
      And I do have an empty file named "lorem/ipsum/amet"
    Then the following files should exist:
        | lorem/ipsum/dolor |
        | lorem/ipsum/amet  |

  Scenario: Check for absence of files
    Then the following files should not exist:
        | lorem/ipsum/dolor |
      
  Scenario: Check for presence of a subset of directories
    Given I do have a directory named "foo/bar"
      And I do have a directory named "foo/bla"
    Then the following directories should exist:
      | foo/bar |
      | foo/bla |
      
  Scenario: Cross-check for absence and presence of directories and files
    Given I do have a directory named "bar/foo"
      And I do have an empty file named "sna/fu"
  
    Then  the following directories should exist:
        | bar/foo |
      And the following files should exist:
        | sna/fu  |

      But the following directories should not exist:
        | foo/bar |
        | foo/bla |
        | sna/fu  |

      And the following files should not exist:
        | bar/foo |
        | bar/ten |
        | foo/one | 
  
  Scenario: check for absence of directories
    Given I do have a directory named "foo/bar"
      And i do have a directory named "foo/bla"
    Then the following step should fail with Spec::Expectations::ExpectationNotMetError:
    """
    Then the following directories should not exist:
      | foo/bar/ |
      | foo/bla/ |
    """
  
  Scenario: Check file contents
    Given I do have a file named "foo" with:
      """
      hello world
      Hi there
      """
    Then the file "foo" should contain "hello world"
      And the file "foo" should contain:
      """
      hello world
      Hi there
      """
    Then the file "foo" should not contain "HELLO WORLD"
      And the file "foo" should not contain:
      """
      HELLO WORLD
      """


  Scenario: @aruba-tmpdir flag runs scenario in tmp/aruba
    When I run "ruby -e \"require 'fileutils'; puts FileUtils.pwd\""
    Then the stdout should contain "tmp/aruba"

  @no-aruba-tmpdir
  Scenario: @no-aruba-tmpdir runs scenario in cwd
    When I run "ruby -e \"require 'fileutils'; puts FileUtils.pwd\""
    Then the stdout should not contain "tmp/aruba"

  @rebase-test @aruba-tmpdir @announce 
  Scenario: clean_up api checks for tmp directory subtree
    Given the rebase-test before block conditions
    When I cd to "../../testdata"
    Then the clean_up api method should fail
      And output should match /outside the tmp subtree and may not be deleted/

  @rebase-test @aruba-tmpdir @announce
  Scenario: @rebase-test tag creates soft links in aruba working directory
    Given the rebase-test before block conditions
    Then the soft links should exist in the aruba working directory

  @rebase-test @aruba-tmpdir @announce
  Scenario: rebase api creats soft links in aruba working directory
    Given the rebase-test before block conditions
      And I create the cwd sub-directory named "rebase_test"
    When I rebase the directory named "rebase_test"
    Then "rebase_test" should have a soft link in the aruba working directory
      And I delete the cwd sub-directory named "rebase_test"


  Scenario: Check file contents with regexp
    Given I do have a file named "foo" with:
      """
      hello world
      """
    Then the file "foo" should match /hel.o world/
    And the file "foo" should not match /HELLO WORLD/


  Scenario: Remove file
    Given I do have a file named "foo" with:
      """
      hello world
      """
    When I remove the file "foo"
    Then the file "foo" should not exist
