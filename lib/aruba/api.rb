require 'tempfile'
require 'rbconfig'
require 'background_process'

module Aruba
  module Api

    def announce_or_puts(msg)
      if(@puts)
        puts(msg)
      else
        announce(msg)
      end
    end


    def append_to_file(file_name, file_content)
      in_current_dir do
        File.open(file_name, 'a') { |f| f << file_content }
      end
    end

    def aruba_working_dir
      @aruba_working_dir
    end

    # This allows before hooks to set aruba's working directory
    # relative to user's cwd
    def aruba_working_dir_set(dir)
      @aruba_working_dir = dir
      dirs_init
    end

    # You can override the default working directory by setting
    # the environment variable ARUBA_WORKING_DIR
    ARUBA_WORKING_DIR_DEFAULT = 'tmp/aruba'   

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


    def assert_exit_status_and_partial_output(expect_to_pass, partial_output)
      assert_partial_output(partial_output)
      if expect_to_pass
        @last_exit_status.should == 0
      else
        @last_exit_status.should_not == 0
      end
    end


    def assert_failing_with(partial_output)
      assert_exit_status_and_partial_output(false, partial_output)
    end


    def assert_partial_output(partial_output)
      combined_output.should =~ regexp(partial_output)
    end


    def assert_passing_with(partial_output)
      assert_exit_status_and_partial_output(true, partial_output)
    end


    def cd(dir)
      dirs << dir
      raise "#{current_dir} is not a directory." \
        unless File.directory?(current_dir)
    end
  

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

  
    def check_exact_file_content(file, exact_content)
      in_current_dir do
        IO.read(file).should == exact_content
      end
    end


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


    def clean_up(dir = current_dir)
      check_tmp_dir = File.expand_path(dir)
      if File.fnmatch('**/tmp/**',check_tmp_dir)
        clean_up!
      else
        raise "#{check_tmp_dir} is outside the tmp " + 
          "subtree and may not be deleted."
      end
    end


    def clean_up!(dir = current_dir)
      FileUtils.rm_rf(dir)
      _mkdir(dir)
    end


    def combined_output
      if @interactive
        interactive_output
      else
        @last_stdout.to_s + @last_stderr.to_s
      end
    end


    def create_dir(dir_name)
      in_current_dir do
        _mkdir(dir_name)
      end
    end


    def create_file(file_name, file_content, check_presence = false)
      in_current_dir do
        raise "expected #{file_name} to be present" if check_presence && !File.file?(file_name)
        _mkdir(File.dirname(file_name))
        File.open(file_name, 'w') { |f| f << file_content }
      end
    end

  
    def create_rvm_gemset(rvm_gemset)
      raise "You haven't specified what ruby version rvm should use." \
        if @rvm_ruby_version.nil?
      run "rvm --create #{@rvm_ruby_version}@#{rvm_gemset}"
    end


    def current_dir
      File.join(*dirs)
    end


    def current_ruby
      File.join(RbConfig::CONFIG['bindir'], 
        RbConfig::CONFIG['ruby_install_name'])
    end

  
    def delete_rvm_gemset(rvm_gemset)
      raise "You haven't specified what ruby version rvm should use." \
        if @rvm_ruby_version.nil?
      run "rvm --force gemset delete #{@rvm_ruby_version}@#{rvm_gemset}"
    end


    def detect_ruby(cmd)
      if cmd =~ /^ruby\s/
        cmd.gsub(/^ruby\s/, "#{current_ruby} ")
      else
        cmd
      end
    end


    COMMON_RUBY_SCRIPTS = \
      /^(?:bundle|cucumber|gem|jeweler|rails|rake|rspec|spec)\s/


    def detect_ruby_script(cmd)
      if cmd =~ COMMON_RUBY_SCRIPTS
        "ruby -S #{cmd}"
      else
        cmd
      end
    end


    def dirs
      @dirs ||= dirs_init
    end


    def dirs_init
      @dirs = []
      @dirs << aruba_working_dir
    end


    def ensure_newline(str)
      str.chomp << "\n"
    end


    def in_current_dir(&block)
      _mkdir(current_dir)
      Dir.chdir(current_dir, &block)
    end

    
    def install_gems(gemfile)
      create_file("Gemfile", gemfile)
      if ENV['GOTGEMS'].nil?
        run("gem install bundler")
        run("bundle --no-color install")
      end
    end


    def interactive_output
      if @interactive
        @interactive.wait(1) || @interactive.kill('TERM')
        @interactive.stdout.read
      else
        ""
      end
    end

    
    def original_env
      @original_env ||= {}
    end


    def pick_up
      @pick_up
    end


    def _mkdir(dir_name)
      FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
    end


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


    def rebase_dirs
      @aruba_rebase_dirs
    end


    def rebase_dirs_add(dirs=nil)
      return unless dirs
      dirs = dirs.lines.to_a if dirs.respond_to?('lines')
      dirs = dirs.flatten
      @aruba_rebase_dirs ||= []
      @aruba_rebase_dirs = (@aruba_rebase_dirs + dirs).uniq
    end


    def rebase_dirs_clear
      @aruba_rebase_dirs = []
    end


    def regexp(string_or_regexp)
      Regexp === string_or_regexp ? string_or_regexp : Regexp.compile(Regexp.escape(string_or_regexp))
    end


    def restore_env
      original_env.each do |key, value|
        ENV[key] = value
      end
    end

=begin
    def run(cmd, fail_on_error=true)
      cmd = detect_ruby(cmd)

      in_current_dir do
        announce_or_puts("$ cd #{Dir.pwd}") if @announce_dir
        announce_or_puts("$ #{cmd}") if @announce_cmd
        ps = BackgroundProcess.run(cmd)
        @last_exit_status = ps.exitstatus # waits for the process to finish
        @last_stdout = ps.stdout.read
        announce_or_puts(@last_stdout) if @announce_stdout
        @last_stderr = ps.stderr.read
      end
=end
    
    def run(cmd, fail_on_error=true)
      cmd = detect_ruby(cmd)

      stderr_file = Tempfile.new('cucumber')
      stderr_file.close
      in_current_dir do
        announce_or_puts("$ cd #{Dir.pwd}") if @announce_dir
        announce_or_puts("$ #{cmd}") if @announce_cmd

        mode = RUBY_VERSION =~ /^1\.9/ ? {:external_encoding=>"UTF-8"} : 'r'
        
        IO.popen("unset BUNDLE_PATH && unset BUNDLE_BIN_PATH && unset BUNDLE_GEMFILE && #{cmd} 2> #{stderr_file.path}", mode) do |io|
          @last_stdout = io.read
          announce_or_puts(@last_stdout) if @announce_stdout
        end

        @last_exit_status = $?.exitstatus
      end

      @last_stderr = IO.read(stderr_file.path)
      announce_or_puts(@last_stderr) if @announce_stderr

      if(@last_exit_status != 0 && fail_on_error)
        fail("Exit status was #{@last_exit_status}. Output:\n#{combined_output}")
      end

      @last_stderr
    end


    def run_interactive(cmd)
      cmd = detect_ruby(cmd)

      in_current_dir do
        @interactive = BackgroundProcess.run(cmd)
      end
    end


    def set_env(key, value)
      announce_or_puts(%{$ export #{key}="#{value}"}) if @announce_env
      original_env[key] = ENV.delete(key)
      ENV[key] = value
    end


    def unescape(string)
      eval(%{"#{string}"})
    end


    def unset_bundler_env_vars
      %w[RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE].each do |key|
        set_env(key, nil)
      end
    end


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


    def user_working_dir
      # This allows us to find the user's original working directory
      @user_working_dir ||= FileUtils.pwd
    end


    def write_interactive(input)
      @interactive.stdin.write(input)
    end

  end #api module
end # aruba module
