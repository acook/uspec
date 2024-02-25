require_relative "uspec_helper"

spec 'file errors are captured' do
  cli = new_cli

  output = outstr do
    cli.harness.file_eval testdir.join('broken_require_spec'), nil
  end

  output.include?('Uspec encountered an error when loading') || output
end

spec 'internal errors are captured' do
  cli = new_cli

  output = outstr do
   cli.harness.spec_eval BasicObject.new, BasicObject.new do
      raise 'block error'
    end
  end

  output.include?('Uspec encountered an internal error') || output
end

spec 'source errors are captured' do
  bo = BasicObject.new
  def bo.inspect
    invalid_for_source_error
  end

  a = [ bo ]

  result = Uspec::Result.new "source error result", a, true
  output = result.inspector

  output.include?('Uspec detected a bug in your source') || output
end
