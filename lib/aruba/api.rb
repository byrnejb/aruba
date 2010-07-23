require 'tempfile'
require 'rbconfig'

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

  def x_ray(dir)
    fail("In x_ray")
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

    if defined?(ENV[ARUBA_WORKING_DIR])
      @aruba_working_dir = [ENV[ARUBA_WORKING_DIR]]
    else
      @aruba_working_dir ||= ['tmp/aruba']
    end

    dirs_init

    clean_up

    rebase_dirs_clear

    if defined?(ENV[ARUBA_REBASE])
      rebase(ENV[ARUBA_REBASE].split(%r{,|;\s*}))
    end

  end

  def cd(dir)
    dirs << dir
    raise "#{current_dir} is not a directory." unless File.directory?(current_dir)
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

  def check_file_content(file, partial_content, expect_match)
    regexp = compile_and_escape(partial_content)
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
      raise "#{check_tmp_dir} is outside the tmp subtree and may not be deleted."
    end
  end

  def clean_up!(dir = current_dir)
    FileUtils.rm_rf(dir)
    _mkdir(dir)
  end

  def combined_output
    @last_stdout.to_s + (@last_stderr.to_s == '' ? \
      '' : "\n#{'-'*70}\n#{@last_stderr}")
  end

  def compile_and_escape(string)
    Regexp.compile(Regexp.escape(string))
  end

  def create_dir(dir_name)
    in_current_dir do
      _mkdir(dir_name)
    end
  end

  def create_file(file_name, file_content)
    in_current_dir do
      _mkdir(File.dirname(file_name))
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end
  
  def create_rvm_gemset(rvm_gemset)
    raise "You haven't specified what ruby version rvm should use." if @rvm_ruby_version.nil?
    run "rvm --create #{@rvm_ruby_version}@#{rvm_gemset}"
  end

  def current_dir
    File.join(*dirs)
  end

  def current_ruby
    if @rvm_ruby_version
      rvm_ruby_version_with_gemset = @rvm_gemset ? "#{@rvm_ruby_version}@#{@rvm_gemset}" : @rvm_ruby_version
      "rvm #{rvm_ruby_version_with_gemset} ruby"
    else
      File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
    end
  end
  
  def delete_rvm_gemset(rvm_gemset)
    raise "You haven't specified what ruby version rvm should use." if @rvm_ruby_version.nil?
    run "rvm --force gemset delete #{@rvm_ruby_version}@#{rvm_gemset}"
  end

  def detect_ruby(cmd)
    if cmd =~ /^ruby\s/
      cmd.gsub(/^ruby\s/, "#{current_ruby} ")
    else
      cmd
    end
  end

  COMMON_RUBY_SCRIPTS = /^(?:bundle|cucumber|gem|jeweler|rails|rake|rspec|spec)\s/

  def detect_ruby_script(cmd)
    if cmd =~ COMMON_RUBY_SCRIPTS
      "ruby -S #{cmd}"
    else
      cmd
    end
  end

  def pick_up
    @pick_up
  end

  def dirs
    @dirs ||= dirs_init
  end

  def dirs_init
    @dirs = []
    @dirs << aruba_working_dir
  end

  def in_current_dir(&block)
    _mkdir(current_dir)
    Dir.chdir(current_dir, &block)
  end

  def install_gems(gemfile)
    create_file("Gemfile", gemfile)
    if ENV['GOTGEMS'].nil?
      run("gem install bundler")
      run("bundle install")
    end
  end

  def _mkdir(dir_name)
    FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
  end

  def unescape(string)
    eval(%{"#{string}"})
  end

  def use_rvm(rvm_ruby_version)
    if File.exist?('config/aruba-rvm.yml')
      @rvm_ruby_version = YAML.load_file('config/aruba-rvm.yml')[rvm_ruby_version] || rvm_ruby_version
    else
      @rvm_ruby_version = rvm_ruby_version
    end
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
    dirs = dirs.to_a.flatten
    @aruba_rebase_dirs ||= []
    @aruba_rebase_dirs = (@aruba_rebase_dirs + dirs).uniq
  end

  def rebase_dirs_clear
    @aruba_rebase_dirs = []
  end

  def run(cmd, fail_on_error=true)
    cmd = detect_ruby_script(cmd)
    cmd = detect_ruby(cmd)

    announce_or_puts("$ #{cmd}") if @announce_cmd

    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    in_current_dir do
      mode = RUBY_VERSION =~ /^1\.9/ ? {:external_encoding=>"UTF-8"} : 'r'
      IO.popen("#{cmd} 2> #{stderr_file.path}", mode) do |io|
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

  def use_rvm_gemset(rvm_gemset, empty_gemset)
    @rvm_gemset = rvm_gemset
    if empty_gemset && ENV['GOTGEMS'].nil?
      delete_rvm_gemset(rvm_gemset)
      create_rvm_gemset(rvm_gemset)
    end
  end

  def user_working_dir
    # This allows us to find the user's original working directory
    @user_working_dir ||= FileUtils.pwd
  end

  end #api module
end # aruba module
