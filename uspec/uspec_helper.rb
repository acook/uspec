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
  strio = StringIO.new
  old_stdout = $stdout
  $stdout = strio

  yield
ensure
  $stdout = old_stdout
end
