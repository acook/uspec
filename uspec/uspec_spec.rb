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

spec 'exit code is the number of failures' do
  capture do
    50.times do
      spec 'fail' do
        false
      end
    end
  end

  $?.exitstatus == 50 || $?
end

spec 'if more than 255 failures, exit status is 255' do
  capture do
    500.times do
      spec 'fail' do
        false
      end
    end
  end

  $?.exitstatus == 255 || $?
end
