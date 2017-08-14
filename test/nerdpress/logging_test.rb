require 'test_helper'

describe NerdPress::Logging do
  let(:log_file) { build_path.join('build.log') }

  before do
    build_path.mkpath unless build_path.exist?
    NerdPress::Logger.setup(log_dir: build_path)
  end

  describe '#logger' do
    it 'returns the Logger instance for the program' do
      object = create_logger_object
      assert_equal NerdPress::Logger.instance, object.logger
    end
  end

  describe 'logging convenience methods' do
    let(:log_file_contents) { log_file.read }

    it 'logs the message with the expected severity' do
      object = create_logger_object

      out, err = capture_subprocess_io do
        object.debug 'Debug message'
        object.error 'Error message'
        object.fatal 'Fatal message'
        object.info 'Info message'
        object.unknown 'Unknown message'
        object.warn 'Warn message'
      end

      assert_match(/DEBUG -- : Debug message/, out)
      assert_match(/DEBUG -- : Debug message/, log_file_contents)

      assert_match(/ERROR -- : Error message/, out)
      assert_match(/ERROR -- : Error message/, log_file_contents)

      assert_match(/FATAL -- : Fatal message/, out)
      assert_match(/FATAL -- : Fatal message/, log_file_contents)

      assert_match(/INFO -- : Info message/, out)
      assert_match(/INFO -- : Info message/, log_file_contents)

      assert_match(/ANY -- : Unknown message/, out)
      assert_match(/ANY -- : Unknown message/, log_file_contents)

      assert_match(/WARN -- : Warn message/, out)
      assert_match(/WARN -- : Warn message/, log_file_contents)

      assert_empty err
    end
  end

  private

  def create_logger_object
    object = Object.new
    class << object
      include NerdPress::Logging
    end
    object
  end
end
