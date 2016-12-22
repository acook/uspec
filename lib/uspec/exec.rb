require 'pathname'
require_relative '../uspec'

class Uspec::Exec
  class << self
    def usage
      warn "uspec - minimalistic ruby testing framework"
      warn "usage: #{File.basename $0} [<file_or_path>...]"
    end

    def run_specs paths
      uspec_exec = self.new paths
      uspec_exec.run_paths
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
      warn "spec/path not found: #{path}"
    end
  end

end
