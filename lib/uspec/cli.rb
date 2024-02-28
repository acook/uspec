require 'pathname'
require_relative '../uspec'

class Uspec::CLI
  def initialize args
    @paths = args
    @pwd = Pathname.pwd.freeze
    @stats = Uspec::Stats.new
    @harness = Uspec::Harness.new self
  end
  attr :stats, :harness

  def usage
    warn "uspec v#{::Uspec::VERSION} - minimalistic ruby testing framework"
    warn "usage: #{File.basename $0} [<file_or_path>...]"
    warn ""
    warn "\t\t--full_backtrace\tshow full backtrace"
    warn "\t\t--\tstop checking paths for options (good if a path begins with a dash)"
    exit 1
  end

  def run_specs
    run_paths
  end

  def invoke
    parse_options @paths
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
    check_options = true

    paths.each do |path|
      run @pwd.join path
    end
  end

  def run path
    p, line = path.to_s.split(?:)
    path = Pathname.new p

    if path.directory? then
      Pathname.glob(path.join('**', '**_spec.rb')).each do |spec|
        run spec
      end
    elsif path.exist? then
      puts "#{path.basename path.extname}:"
      harness.file_eval path, line
    else
      warn "path not found: #{path}"
    end
  end

  def parse_options args
    usage unless (args & %w[-h --help -? /? -v --version]).empty?

    args.each_with_index do |arg, i|
      if arg == '--' then
        return args
      elsif arg == '--full_backtrace' then
        Uspec::Errors.full_backtrace!
        args.delete_at i
      elsif arg[0] == ?- then
        warn "unknown option: #{arg}"
        args.delete_at i
      end
    end
  end
end
