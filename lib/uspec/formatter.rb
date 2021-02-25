require "toisb"

module Uspec
  # subclass this to build your own formatter
  class Formatter
    class << self
      def inherited(subklass)
        registry[subklass.name.split("::").last] = subklass
      end

      def registry
        @registry ||= Hash.new
      end
    end

    def initialize options
      @options = options
    end

    # this is run before a file is executed
    def pre_suite options
      # perhaps show options.paths
      # or something from options.args
    end

    # run before the file is loaded
    def pre_file paths, stats
    end

    # gets tacked onto the beginning
    # just a convinience
    def file_prefix
    end

    # receives the path of the file being run
    def file path
      raise NotImplementedError
    end

    # gets tacked onto the end
    # just a convinience
    def file_suffix
    end

    # gets tacked onto the beginning
    # just a convinience
    def test_prefix
    end

    # this receives the name of the test
    # before it is executed
    def test description, tags = []
      raise NotImplementedError
    end

    # gets tacked onto the end
    # just a convinience
    def test_suffix
    end

    # gets tacked onto the beginning
    # just a convinience
    def result_prefix
    end

    # this formats the result for output
    def result result_object
      raise NotImplementedError
    end

    # gets tacked onto the end
    # just a convinience
    def result_suffix
    end

    # this is run after a file has completed
    def post_file path, prefix
    end

    # this is run after everything else except the summary
    def post_suite options
    end

    # this is displayed at the end after all tests
    def summary stats
      raise NotImplementedError
    end

    # any time Uspec needs to display information
    # about an error it detects outside of a spec
    # this will determine what it looks like
    #
    # - exception is the exception object captured by rescue
    # - info is the additional information provided by Uspec
    #
    # you can override this if you want
    def internal_error exception, info
      [
        Uspec::Terminal.esc("3;31;47"), " ",
        exception.class, " : ", exception.message,
        " ", Uspec::Terminal.esc("0"), "\e[K\n\n",
        info, "\n\n",
        "\t", exception.backtrace.join("\n\t"), "\n"
      ].join
    end

    # use this method
    # instead of `result_object.raw.inspect`
    def inspector result_object
      result_object.handler.inspector!
    rescue Exception => error
      return result_object.handler.simple_inspector if error.message.include? result_object.handler.get_id

      error_file, error_line, _ = error.backtrace[4].split ?:

      internal_error error, <<-MSG
      Uspec detected a bug in your source code!
      Calling #inspect on an object will recusively call #inspect on its instance variables and contents.
      If one of those contained objects does not have an #inspect method you will see this message.
      You will also get this message if your #inspect method or one of its callees raises an exception.
      This is most likely to happen with BasicObject and its subclasses.

      If you think this is a bug in Uspec please report it: https://github.com/acook/uspec/issues/new

      Error may have occured in test `#{result_object.spec}` in file `#{error_file}` on line ##{error_line}.
      MSG
    end

  end
end

