require_relative '../lib/uspec'
extend Uspec

def capture
  readme, writeme = IO.pipe
  pid = fork do
    $stdout.reopen writeme
    readme.close

    yield
  end

  writeme.close
  output = readme.read
  Process.waitpid(pid)

  output
end

spec 'catches errors' do
  output = capture do
    spec 'exception' do
      raise 'test exception'
    end
  end

  output.include? 'Exception'
end

spec 'complains when spec block returns non boolean' do
  output = capture do
    spec 'whatever' do
      "string"
    end
  end

  output.include? 'Unknown Result'
end

spec 'marks test as pending when no block supplied' do
  output = capture do
    spec 'pending test'
  end

  output.include? 'pending'
end

spec 'should not define DSL methods on arbitrary objects' do
  !(Array.respond_to? :spec)
end
