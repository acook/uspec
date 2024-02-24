require 'pathname'
require_relative '../uspec'

class Uspec::CLI
  def initialize args
    usage unless (args & %w[-h --help -? /? -v --version]).empty?

    @paths = args
    @pwd = Pathname.pwd.freeze
    @stats = Uspec::Stats.new
    @harness = Uspec::Harness.new self
  end
  attr :stats, :harness

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
    die!
  end

  def exit_code
    [@stats.failure.size, 255].min
  end

  def handle_interrupt! type = Interrupt
    if SignalException === type || SystemExit === type then
      if type === Module then
        err = type
        msg = "signal"
      else
        err = type.class
        msg = type.message
      end
      puts "Uspec received #{err} #{msg} - exiting!"
      die!
    end
  end

  def die!
    puts @stats.summary
    exit exit_code
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
      harness.file_eval path
    else
      warn "path not found: #{path}"
    end
  end

end
