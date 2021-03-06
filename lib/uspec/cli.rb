require 'pathname'
require_relative '../uspec'

class Uspec::CLI
  def initialize args
    usage unless (args & %w[-h --help -? /? -v --version]).empty?

    @paths = args
    @pwd = Pathname.pwd.freeze
    @stats = Uspec::Stats.new
    @dsl = Uspec::DSL.new self
  end
  attr :stats, :dsl

  def usage
    warn "uspec v#{::Uspec::VERSION} - minimalistic ruby testing framework"
    warn "usage: #{File.basename $0} [<file_or_path>...]"
    exit 1
  end

  def run_specs
    run_paths
  end

  def invoke
    run_specs
    puts @stats.summary
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
      puts "#{path.basename path.extname}:"
      dsl.instance_eval(path.read, path.to_s)
    else
      warn "path not found: #{path}"
    end
  rescue Exception => error

    error_file, error_line, _ = error.backtrace.first.split ?:

    message = <<-MSG
      #{error.class} : #{error.message}

      Uspec encountered an error when loading a test file.
      This is probably a typo in the test file or the file it is testing.

      If you think this is a bug in Uspec please report it: https://github.com/acook/uspec/issues/new

      Error occured when loading test file `#{spec || path}`.
      The origin of the error may be in file `#{error_file}` on line ##{error_line}.

\t#{error.backtrace[0,3].join "\n\t"}
    MSG
    puts
    warn message
    stats.failure << Uspec::Result.new(message, error, caller)
  end

end
