begin
  require 'bundler'
  Bundler.require(:test, :development)
rescue LoadError => err
  nil
end
require 'open3'
require 'stringio'

require_relative '../lib/uspec'
extend Uspec

Uspec::Errors.full_backtrace!

def capture
  readme, writeme = IO.pipe
  pid = fork do
    $stdout.reopen writeme
    $stderr.reopen writeme
    readme.close

    yield
  end

  writeme.close
  output = readme.read
  Process.waitpid(pid)

  output
end

def outstr
  old_stdout = $stdout
  old_stderr = $stderr

  outio = StringIO.new
  $stdout = outio

  errio = StringIO.new
  $stderr = errio

  val = yield

  outio.string + errio.string
ensure
  $stdout = old_stdout
  $stderr = old_stderr
end

def root
  Pathname.new(__FILE__).parent.parent
end

def exdir
  root.join('example_specs')
end

def specdir
  root.join('uspec')
end

def testdir
  specdir.join('test_specs')
end

def new_cli path  = '.'
  Uspec::CLI.new(Array(path))
end

def run_specs path
  new_cli(path).run_specs
end
