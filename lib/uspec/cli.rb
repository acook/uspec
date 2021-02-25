require 'pathname'
require 'slop'
require_relative '../uspec'
require_relative 'default_formatter'

class Uspec::CLI
  def initialize args
    @slop = Slop::Options.new do |o|
      o.banner = 'usage: uspec [options] [<paths>...]'
      o.on '-v', '--version' do
        print ?v, Uspec::VERSION, ?\n
        exit 1
      end
      o.on '-h', '--help', "you're looking at it" do
        usage
      end
      o.separator "\t<paths>    a list of files or paths to test"
      o.separator "\t\t   defaults to: \"#{DEFAULT_SEARCH_DIRS.join " "}\""
    end

    @opts = Slop::Parser.new(@slop).parse args
    @pwd = Pathname.pwd.freeze
    @stats = Uspec::Stats.new
    @format = Uspec::DefaultFormatter.new self
    @dsl = Uspec::DSL.new self
  end
  attr :opts, :stats, :dsl, :format

  DEFAULT_SEARCH_DIRS = ['spec', 'uspec', 'test']

  def usage
    warn "uspec v#{::Uspec::VERSION} - minimalistic ruby testing framework"
    warn @slop
    exit 1
  end

  def run_specs
    run_paths
  end

  def invoke
    print format.pre_suite self
    run_specs
    print format.post_suite(self), format.summary(stats)
    exit exit_code
  end

  def exit_code
    [(@stats.failure.size + @stats.special.size), 255].min
  end

  def paths
    return @paths if @paths

    @paths = @opts.arguments

    if @paths.empty? then
      @paths = Array.new
      DEFAULT_SEARCH_DIRS.each do |path|
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
      print format.pre_file(path, stats), format.file_prefix, format.file(path), format.file_suffix
      dsl.instance_eval(path.read, path.to_s)
      print format.post_file(path, stats)
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
    warn "\n", message
    stats.special << Uspec::Result.new(message, error, caller, self)
  end

end
