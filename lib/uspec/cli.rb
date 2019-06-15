require 'pathname'
require_relative '../uspec'

class Uspec::CLI
  class << self
    def usage
      warn "uspec - minimalistic ruby testing framework"
      warn "usage: #{File.basename $0} [<file_or_path>...]"
    end

    def run_specs paths
      uspec_cli = self.new paths
      uspec_cli.run_paths
    end

    def invoke args
      if (args & %w[-h --help -? /?]).empty? then
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
  rescue LoadError => result
    formatter = Uspec::Formatter.new
    print ' -- FAILED TO LOAD TEST FILE DUE TO: '
    Uspec::Stats.results << result
    puts formatter.colorize(result, result.backtrace)
  end

end
