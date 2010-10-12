require 'tempfile'
require 'rbconfig'
require 'background_process'

module Aruba
  module Api

    # announce_or_puts(msg) is an internal helper method for
    # reproducing test process output in the Aruba run.
    #
    def announce_or_puts(msg)
      if(@puts)
        puts(msg)
      else
        announce(msg)
      end
    end

    # append_to_file is used to add data to the end of a
    # file in a step definition.  The data is of course
    # a string obtained from the feature.  A typical invocation
    # looks like:
    #
    #     Given I do have a file named "foo/bar/example.rb" with:
    #     """
    #     puts "hello world"
    #     """
    #
    def append_to_file(file_name, file_content)
      in_current_dir do
        File.open(file_name, 'a') { |f| f << file_content }
      end
    end

    # aruba_working_dir simple returns the value of the current
    # directory that aruba is running its features in. This is
    # set using the aruba_working_dir_set method from within the
    # step definitions or through the environment variable
    # ARUBA_WORKING_DIR 
    #
    def aruba_working_dir
      @aruba_working_dir
    end

    # aruba_working_dir_set allows before hooks to set aruba's
    # working directory relative to user's cwd.
    #
    def aruba_working_dir_set(dir)
      @aruba_working_dir = dir
      dirs_init
    end

    # You can override the default working directory by setting
    # the environment variable ARUBA_WORKING_DIR
    #
    ARUBA_WORKING_DIR_DEFAULT = 'tmp/aruba'   

    # aruba_working_dir_init initializes the aruba_working_dir to 
    # either the default value specified in ARUBA_WORKING_DIR_DEFAULT
    # or the value of the the environment variable ARUBA_WORKING_DIR
    # if present.
    #
    # This method also rebases the list of comma delimited directories
    # contained in the ARUBA_REBASE environmental variable, if found.
    #
    def aruba_working_dir_init

      @aruba_working_dir = [ARUBA_WORKING_DIR_DEFAULT]

      if defined?(ENV[ARUBA_WORKING_DIR])
        @aruba_working_dir = [ENV[ARUBA_WORKING_DIR]] 
      end

      dirs_init
      clean_up
      rebase_dirs_clear

      if defined?(ENV[ARUBA_REBASE])
        rebase(ENV[ARUBA_REBASE].split(%r{,|;\s*}))
      end
    end

    # assert_exit_status_and_partial_output(pass_or_fail, output) is an
    # internal helper method not really should not be used in a step definition.
    #
    def assert_exit_status_and_partial_output(expect_to_pass, partial_output)
      assert_partial_output(partial_output)
      if expect_to_pass
        @last_exit_status.should == 0
      else
        @last_exit_status.should_not == 0
      end
    end

    # assert_failing_with(output) uses assert_exit_status_and_partial_output.
    # It passes the exit status expectation as false (fail) and the text
    # expected in the output to that method.
    #
    def assert_failing_with(partial_output)
      assert_exit_status_and_partial_output(false, partial_output)
    end

    # assert_partial_output(partial_output)
    def assert_partial_output(partial_output)
      combined_output.should =~ regexp(partial_output)
    end

    # assert_passing_with(output) uses assert_exit_status_and_partial_output.
    # It passes the exit status expectation as true (pass) and the text
    # expected in the output to that method.
    #
    def assert_passing_with(partial_output)
      assert_exit_status_and_partial_output(true, partial_output)
    end

    # cd(path) changes aruba's working directory (awd) to path. 
    #
    # Usage:
    #   When I cd to "foo/nonexistant"
    #
    def cd(dir)
      dirs << dir
      raise "#{current_dir} is not a directory." \
        unless File.directory?(current_dir)
    end
  
    # check_directory_presence(paths, expect_presence) operates on
    # an enumable collection of paths and determines if each exits
    # passes if they do when expect_presence = true and 
    # passes if they do not when expect_presence = false.
    # 
    # Usage:
    #   Then the following directories should exist:
    #     | foo/bar |
    #     | foo/bla |
    #
    #   Then the following directories should not exist:
    #     | bar/foo |
    #     | bar/none |
    #
    def check_directory_presence(paths, expect_presence)
      in_current_dir do
        paths.each do |path|
          if expect_presence
            File.should be_directory(path)
          else
            File.should_not be_directory(path)
          end
        end
      end
    end

    # check_exact_file_content(file, exact_content) veries that
    # the specified file contains exactly the provided text.
    #
    # Usage:
    #   Then the file "foo" should contain exactly:
    #     """
    #     My file should have this.
    #     And this
    #     """
    #
    def check_exact_file_content(file, exact_content)
      in_current_dir do
        IO.read(file).should == exact_content
      end
    end

    # check_file_content(file, partial_content, expect_match) veries that
    # the specified file contains at least the provided text.
    #
    # Usage:
    #   Then the file "foo" should contain:
    #     """
    #     My file should have this.
    #     And this
    #     """
    #
    #   Then the file "foo" should not contain:
    #     """
    #     My file should not have this.
    #     And this
    #     """
    #
    #   Then I do have the file named "foo" with "blah"
    #
    def check_file_content(file, partial_content, expect_match)
      regexp = regexp(partial_content)
      in_current_dir do
        content = IO.read(file)
        if expect_match
          content.should =~ regexp
        else
          content.should_not =~ regexp
        end
      end
    end

    # check_file_presence(paths, expect_presence) operates on files in
    # a fashion similare to check_directory_presence.  it enumerates
    # on a collection of file names and passes or fails on the first
    # existance or abscence according to the expect_presence setting.
    #
    # Usage:
    #   When the following files should exist:
    #   """
    #   blah/file.tst
    #   bare/file1.test
    #   foor/barnet.tst
    #   """
    #
    def check_file_presence(paths, expect_presence)
      in_current_dir do
        paths.each do |path|
          if expect_presence
            File.should be_file(path)
          else
            File.should_not be_file(path)
          end
        end
      end
    end
  
    # clean_up(dir = current_dir) is an internal helper method that empties
    # the current working directory of all content. It is used in the 
    # Aruba before hook to clear out the awd at the start of each scenario.
    #
    # It will not clear any directory that does not contain the directory
    # <tt>/tmp/</tt> somewhare in its path.
    #
    def clean_up(dir = current_dir)
      check_tmp_dir = File.expand_path(dir)
      if File.fnmatch('**/tmp/**',check_tmp_dir)
        clean_up!
      else
        raise "#{check_tmp_dir} is outside the tmp " + 
          "subtree and may not be deleted."
      end
    end

    # clean_up!(dir = current_dir).  Internal helper method.  Does not check
    # for tmp directory path.
    #
    def clean_up!(dir = current_dir)
      FileUtils.rm_rf(dir)
      _mkdir(dir)
    end

    # combined_output is an internal helper methiod that concatenates the
    # contents of $stdout with $stderr.
    #
    # Usage:
    #   Then output should contain:
    #     """
    #     toto
    #     red shoes
    #     """
    #   Then output should contain "toto"
    #   Then output should contain exactly:
    #     """
    #     toto
    #     red shoes
    #     """
    #   Then output should contain exactly "toto"
    #   Then output should not contain:
    #     """
    #     toto
    #     red shoes
    #     """
    #   Then output should not contain "toto"
    #   Then output should not contain exactly:
    #     """
    #     toto
    #     red shoes
    #     """
    #   Then output should not contain exactly "toto"
    #   
    #
    def combined_output
      if @interactive
        interactive_output
      else
        @last_stdout.to_s + @last_stderr.to_s
      end
    end

    # create_dir(dir_name) creates the given directory name within the awd
    # subject to normal filesystem restrictions.
    # 
    # `Usage:
    #   Given I do have a directory named "foobar"$
    #
    def create_dir(dir_name)
      in_current_dir do
        _mkdir(dir_name)
      end
    end

    # create_file(file_name, file_content, check_presence = false) creates
    # the given file name in the awd and fills it with the provided content,
    # optionally checking first to see if the file exists.
    #
    # Usage:
    #   When we do have a file named "foo" containing:
    #     """
    #     This is in my new file.
    #     And so is this
    #     """
    #   When I do have an empty file named "empty
    #   "
    def create_file(file_name, file_content, check_presence = false)
      in_current_dir do
        raise "expected #{file_name} to be present" if check_presence && !File.file?(file_name)
        _mkdir(File.dirname(file_name))
        File.open(file_name, 'w') { |f| f << file_content }
      end
    end

    # current_dir is an internal helper method that returns the current awd
    # as a path.
    #
    def current_dir
      File.join(*dirs)
    end

    # current_ruby is an internal helper method that returns the 
    # path to the currently active Ruby VM.
    #
    def current_ruby
      File.join(RbConfig::CONFIG['bindir'], 
        RbConfig::CONFIG['ruby_install_name'])
    end

    # detect_ruby(cmd) is an internal helper method that checks to see
    # if the Aruba test cli command is ruby itself and returns the
    # value of current_ruby to the <tt>run</tt> method and the value
    # of cmd otherwise.
    #
    def detect_ruby(cmd)
      if cmd =~ /^ruby\s/
        cmd.gsub(/^ruby\s/, "#{current_ruby} ")
      else
        cmd
      end
    end

    # This provides a regexp of commonly encountered Ruby scripts
    # for use in testing Aruba itself.
    #
    COMMON_RUBY_SCRIPTS = \
      /^(?:bundle|cucumber|gem|jeweler|rails|rake|rspec|spec)\s/ 

    # detect_ruby_script is an internal helper script used in testing
    # Aruba itself.
    #
    def detect_ruby_script(cmd)
      if cmd =~ COMMON_RUBY_SCRIPTS
        "ruby -S #{cmd}"
      else
        cmd
      
      end
    end

    # dirs is an internal helper method that returns the current
    # directory components as an array.
    #
    def dirs
      @dirs ||= dirs_init
    end

    # dirs_init is an internal helper method that intializes the 
    # content of the dirs to the value of aruba_working_dir.
    #
    def dirs_init
      @dirs = []
      @dirs << aruba_working_dir
    end

    # ensure_newline(str) is an internal helper method used to test interactive
    # CLI programs with Aruba.
    #
    def ensure_newline(str)
      str.chomp << "\n"
    end

    # in_current_dir(&block) is an internal helper method wherein all the magic
    # of Aruba takes place.  It uses the value of current_dir to determine
    # what directory to change to before running Aruba steps.
    #
    def in_current_dir(&block)
      _mkdir(current_dir)
      Dir.chdir(current_dir, &block)
    end

    # install_gems(gemfile) internal helper method that uses Bundler to
    # install the gems specified int he given Gemfile name into the
    # current Ruby VM.
    #
    def install_gems(gemfile)
      create_file("Gemfile", gemfile)
      if ENV['GOTGEMS'].nil?
        run("gem install bundler")
        run("bundle --no-color install")
      end
    end

    # interactive_output an internal  helper method that provides the contents
    # of $stdout from interactive Aruba processes.
    # 
    def interactive_output
      @_interactive ||= if @interactive
        @interactive.wait(1) || @interactive.kill('TERM')
        @interactive.stdout.read
      else
        ""
      end
    end

    # original_env is an internal helper method that returns a hash of the
    # original env variables and their values for restore_original_env
    #
    def original_env
      @original_env ||= {}
    end

    # _mkdir(dir_name) is an internal helper name that does exactly as its
    # stem suggests, performs a mkdir using the provided name.
    #
    def _mkdir(dir_name)
      FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
    end

    # rebase(dirs=nil) creates a symbolic link in the awd to each directory
    # contained in the passed array that are named relative to the user's
    # cwd.  It first checkes that the awd path contains a directory named
    # <tt>/tmp/</tt> and fails if it does not.
    #
    # Usage:
    #   When I rebase the directory "bar/foo"$
    #
    def rebase(dirs=nil)

      rebase_dirs_add(dirs) if dirs
      working_dir = File.expand_path(File.join(FileUtils.pwd, aruba_working_dir))

      if rebase_dirs and File.fnmatch('**/tmp/**', working_dir)
        rebase_dirs.each do |dir|
          FileUtils.ln_s(File.join(user_working_dir, dir.to_s), 
            working_dir, :force => true)
        end
      else
        raise "Aruba's working directory, #{working_dir}, \n" +
          "is outside the tmp subtree and may not be rebased."
      end
    end

    # rebase_dirs is an internal helper mehtod that returns the
    # array containing all the directories to be rebased.
    # 
    def rebase_dirs
      @aruba_rebase_dirs
    end

    # rebase_dirs_add(dirs=nil) is an internal helper method that
    # adds directory names to the rebase_dirs array.
    #
    def rebase_dirs_add(dirs=nil)
      return unless dirs
      dirs = dirs.lines.to_a if dirs.respond_to?('lines')
      dirs = dirs.flatten
      @aruba_rebase_dirs ||= []
      @aruba_rebase_dirs = (@aruba_rebase_dirs + dirs).uniq
    end

    # rebase_dirs_clear is an internal helper method that empties
    # the rebase_dirs array.
    #
    def rebase_dirs_clear
      @aruba_rebase_dirs = []
    end

    # regexp(string_or_regexp) is an internal helper method used to compile
    # regexp for use in step definations.
    #
    # Usage:
    #   Then should (pass|fail) with regexp:
    #     """
    #     /^Better start with this/
    #     """
    #   Then stderr should contain "this"
    #   Then stdout should contain "this"
    #   Then stderr should not contain "this"
    #   Then stdout should not contain "this"
    #   
    def regexp(string_or_regexp)
      Regexp === string_or_regexp ? string_or_regexp : Regexp.compile(Regexp.escape(string_or_regexp))
    end

    # restore_env is an internal helper method that restors the user's original
    # environment at the completion of a scenario using Aruba.
    #
    def restore_env
      original_env.each do |key, value|
        ENV[key] = value
      end
    end
    
    # run(cmd, fail_on_error=true) is the internal helper method that actually
    # runs the test executable, optionally failing if the exit status != 0.
    #
    # Usage:
    #   When I run "ruby -e 'puts "hello world"'
    #   When I run "ruby -e 'print "Name? "; my_name = gets'" interactively
    #   When I run "ruby -e 'fail' with errors
    #   When I run "ruby -e 'exit' without errors
    #   When exit status should be 0
    #   When exit status should not be 0
    #
    def run(cmd, fail_on_error=true)
      cmd = detect_ruby(cmd)


      in_current_dir do
        announce_or_puts("$ cd #{Dir.pwd}") if @announce_dir
        announce_or_puts("$ #{cmd}") if @announce_cmd
        ps = BackgroundProcess.run(cmd)
        @last_stdout = ps.stdout.read 
        announce_or_puts(@last_stdout) if @announce_stdout
        @last_stderr = ps.stderr.read
        announce_or_puts(@last_stderr) if @announce_stderr
        @last_exit_status = ps.exitstatus # Waits for process to finish
      end

      if(@last_exit_status != 0 && fail_on_error)
        fail("Exit status was #{@last_exit_status}. Output:\n#{combined_output}")
      end

      @last_stderr
    end
    
    # run_interactive(cmd) is an internal helper method that runs CLI
    # programs returning user input.
    #
    # Usage:
    #   When I run "ruby -e 'print "Name? "; my_name = gets'" interactively
    #
    def run_interactive(cmd)
      cmd = detect_ruby(cmd)

      in_current_dir do
        @interactive = BackgroundProcess.run(cmd)
      end
    end

    # set_env(key, value) is an internal helper method that sets a hash of the
    # original env variables and their values for restore_original_env
    #
    def set_env(key, value)
      announce_or_puts(%{$ export #{key}="#{value}"}) if @announce_env
      original_env[key] = ENV.delete(key)
      ENV[key] = value
    end

    # unescape(string) is an internal helper method that evals the passed
    # string.
    #
    def unescape(string)
      eval(%{"#{string}"})
    end

    # unset_bundler_env_vars is an internal helper method that unsets
    # enviromental variables used by the Bundler gem.
    #
    def unset_bundler_env_vars
      %w[RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE].each do |key|
        set_env(key, nil)
      end
    end

    # use_clean_gemset(gemset) takes a gemset name and creates it
    # using gemset.
    #
    # Usage:
    #   When I am using a clean gemset "my_global*)"
    #
    def use_clean_gemset(gemset)
      run(%{rvm gemset create "#{gemset}"}, true)
      if @last_stdout =~ /'#{gemset}' gemset created \((.*)\)\./
        gem_home = $1
        set_env('GEM_HOME', gem_home)
        set_env('GEM_PATH', gem_home)
        set_env('BUNDLE_PATH', gem_home)

        paths = (ENV['PATH'] || "").split(File::PATH_SEPARATOR)
        paths.unshift(File.join(gem_home, 'bin'))
        set_env('PATH', paths.uniq.join(File::PATH_SEPARATOR))

        run("gem install bundler", true)
      else
        raise "I didn't understand rvm's output: #{@last_stdout}"
      end
    end

    # user_working_dir is an internal helper method used by the rebase method
    # that initially sets and then returns the user's pwd.
    #
    def user_working_dir
      # This allows us to find the user's original working directory
      @user_working_dir ||= FileUtils.pwd
    end

    # write_interactive(input) writes the provided string to $stdin of
    # the interactive process run by Aruba.
    # Usage
    #   When I type "the answwer is 42"
    #
    def write_interactive(input)
      @interactive.stdin.write(input)
    end

  end #api module
end # aruba module
