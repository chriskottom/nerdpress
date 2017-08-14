require 'test_helper'
require 'pathname'

describe NerdPress::Logger do
  describe 'setup' do
    let(:log_file)    { build_path.join('build.log') }
    let(:log_message) { 'Testing testing 1-2-3' }

    after do
      build_path.rmtree if build_path.exist?
    end

    it 'can create a Logger with outputs to a file and STDOUT' do
      logger = NerdPress::Logger.setup(log_dir: build_path)
      assert_instance_of ::Logger, logger

      out, err = capture_subprocess_io do
        NerdPress::Logger.instance.info log_message
      end

      assert_match(/#{log_message}/, out)
      assert_empty err
      assert_match(/#{log_message}/, log_file.read)
    end

    it 'creates a Logger instance on STDOUT by default' do
      NerdPress::Logger.setup
      out, err = capture_subprocess_io do
        NerdPress::Logger.instance.info log_message
      end

      assert_match(/#{log_message}/, out)
      assert_empty err
      refute log_file.exist?, 'Expected log file not to exist'
    end

    it "defaults to log level :debug" do
      NerdPress::Logger.setup
      assert Logger::DEBUG, NerdPress::Logger.instance.level
    end

    it "can set the log level" do
      NerdPress::Logger.setup(log_level: :warn)
      assert Logger::WARN, NerdPress::Logger.instance.level
    end
  end
end
