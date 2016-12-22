require 'pathname'
require_relative '../uspec'

module Uspec::Exec
  module_function

  def run_specs paths
    if paths.empty? then
      ['spec', 'uspec', 'test'].each do |path|
        paths << path if Pathname.new(path).directory?
      end
    end

    @pwd = Pathname.pwd

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

  def usage
    warn "uspec - minimalistic ruby testing framework"
    warn "usage: #{File.basename $0} [<file_or_path>...]"
    exit 1
  end
end
