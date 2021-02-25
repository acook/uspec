require 'pathname'
require_relative '../uspec'
require_relative 'default_formatter'

class Uspec::CLI
  def initialize args
    usage unless (args & %w[-h --help -? /? -v --version]).empty?

    @paths = @args = args
    @pwd = Pathname.pwd.freeze
    @stats = Uspec::Stats.new
    @format = Uspec::DefaultFormatter.new self
    @dsl = Uspec::DSL.new self
  end
  attr :args, :paths, :stats, :dsl, :format

  def usage
    warn "uspec v#{::Uspec::VERSION} - minimalistic ruby testing framework"
    warn "usage: #{File.basename $0} [<file_or_path>...]"
    exit 1
  end

  def run_specs
    run_paths
  end

  def invoke
    print format.pre_suite self
    run_specs
    print format.post_suite self
    print format.summary stats
    exit exit_code
  end

  def exit_code
    [@stats.failure.size, 255].min
  end

  def paths
    if @paths.empty? then
      ['spec', 'uspec', 'test'].each do |path|
        @paths << path if Pathname.new(path).directory?
      end
    end

    @paths
  end

  def run_paths
    paths.each do |path|
      run @pwd.join path
    end
  end

  def run path
    spec = nil
    if path.directory? then
      Pathname.glob(path.join('**', '**_spec.rb')).each do |spec|
        run spec
      end
    elsif path.exist? then
      print format.pre_file path, stats
      print format.file_prefix
      print format.file path
      print format.file_suffix
      dsl.instance_eval(path.read, path.to_s)
      print format.post_file path, stats
    else
      warn "path not found: #{path}"
    end
  rescue Exception => error

    error_file, error_line, _ = error.backtrace.first.split ?:

    message = format.internal_error error, <<-MSG
      Uspec encountered an error when loading a test file.
      This is probably a typo in the test file or the file it is testing.

      If you think this is a bug in Uspec please report it: https://github.com/acook/uspec/issues/new

      Error occured when loading test file `#{spec || path}`.
      The origin of the error may be in file `#{error_file}` on line ##{error_line}.
    MSG
    warn
    warn message
    stats.failure << Uspec::Result.new(message, error, caller, self)
  end

end
