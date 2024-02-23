begin
  require 'pry'
rescue LoadError => err
  nil
end
require 'open3'

require_relative '../lib/uspec'
extend Uspec

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
