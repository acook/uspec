require_relative "uspec_helper"

spec 'catches errors' do
  output = capture do
    spec 'exception' do
      raise 'test exception'
    end
  end

  output.include?('Exception') || output
end

spec 'catches even non-StandardError-subclass exceptions' do
  output = capture do
    spec 'not implemented error' do
      raise ::NotImplementedError, 'test exception'
    end
  end

  output.include?('Exception') || output
end

spec 'Uspec exits when sent a termination signal' do
  path = testdir.join('kill_this_spec')

  stdin, allout, thread = Open3.popen2e "#{testdir}/kill_this_script.sh \"#{path}\""
  stdin.close
  output = allout.read

  begin
    Process.waitpid(thread.pid)
  rescue Errno::ECHILD
    nil
  end

  summary_match = output.match(/0.*successful.*,.*1.*failed.*,.*0.*pending/)
  no_copy_match = output.match(/2.{0,5}pending/) # previous versions continued after "exiting"

  (!!summary_match && !no_copy_match) || output
end

spec 'complains when spec block returns non boolean' do
  output = capture do
    spec 'whatever' do
      "string"
    end
  end

  output.include?('Failed') || output
end

spec 'marks test as pending when no block supplied' do
  path = testdir.join('pending_spec')

  output = capture do
    exec "#{root}/bin/uspec #{path}"
  end

  output.include?('1 pending') || output
end

spec 'should not define DSL methods on arbitrary objects' do
  !(Array.respond_to? :spec)
end

spec 'when return used in spec, capture it as an error' do
  path = testdir.join('return_spec')

  output = capture do
    exec "#{root}/bin/uspec #{path}"
  end

  output.include?('Invalid return') || output.include?('Spec did not return a boolean value') || output
end

spec 'when break used in spec, capture it as an error' do
  path = testdir.join('break_spec')

  output = capture do
    exec "#{root}/bin/uspec #{path}"
  end

  output.include?('Invalid break') || output.include?('Spec did not return a boolean value') || output
end

spec 'when instance variables are defined in the DSL instance, they are available in the spec body' do
  path = testdir.join('ivar_spec')

  output = capture do
    exec "#{root}/bin/uspec #{path}"
  end

  output.include?('1 successful') || output
end

spec 'when methods are defined in the DSL instance, they are available in the spec body' do
  path = testdir.join('method_spec')

  output = capture do
    exec "#{root}/bin/uspec #{path}"
  end

  output.include?('1 successful') || output
end
