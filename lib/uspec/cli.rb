require 'pathname'
require_relative '../uspec'

class Uspec::CLI
  class << self
    def usage
      warn "uspec v#{::Uspec::VERSION} - minimalistic ruby testing framework"
      warn "usage: #{File.basename $0} [<file_or_path>...]"
    end

    def run_specs paths
      uspec_cli = self.new paths
      uspec_cli.run_paths
    end

    def invoke args
      if (args & %w[-h --help -? /? -v --version]).empty? then
        run_specs args
      else
        usage
      end
    end
  end

  def initialize paths
    @paths = paths
    @pwd = Pathname.pwd.freeze
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
      Uspec::DSL.instance_eval(path.read, path.to_s)
    else
      warn "path not found: #{path}"
    end
  rescue Exception => error
    message = <<-MSG
      Uspec encountered an error when loading a test file!
      This is probably a typo in the test file but if you think this is a bug in Uspec please report it!
      https://github.com/acook/uspec/issues/new
      Error may have occured in test file: #{spec || path || error.backtrace.first}
      #{error.class} : #{error.message}
      #{error.backtrace[0..2].join "\n\t"}
    MSG
    puts
    warn message
    ::Uspec::Stats.results << ::Uspec::Result.new(message, error, caller)
  end

end
