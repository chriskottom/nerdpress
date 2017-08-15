require 'test_helper'

describe NerdPress::Project do
  let(:project_path) { './test/fixtures/project' }
  let(:project) { NerdPress::Project.new(project_path) }

  describe '#initialize' do
    it 'sets the home directory' do
      home_dir = './test/fixtures/project'
      project = NerdPress::Project.new(home_dir)
      assert_equal Pathname.new(home_dir).expand_path, project.home_directory
    end

    it 'fails when given a nonexistent directory' do
      err = assert_raises ArgumentError do
        NerdPress::Project.new('/path/does/not/exist')
      end

      assert_equal 'Path does not exist', err.message
    end
  end

  describe '#configure' do
    it 'loads the configuration from the requested YAML file' do
      assert project.config.nil?, 'Expected project to be unconfigured'

      config_file = './test/fixtures/alt_config.yml'
      project.configure(config_file)
      assert_equal './test/tmp/different/path', project.config.build_dir
    end

    it 'accepts an additional configuration block' do
      project.configure do |config|
        config.foo = 'bar'
      end

      assert_equal 'bar', project.config.foo
    end

    describe "when the config file doesn't exist" do
      it 'raises an error' do
        err = assert_raises ArgumentError do
          project.configure('does/not/exist.yml')
        end

        assert_equal 'Configuration not found: does/not/exist.yml', err.message
      end
    end

    describe 'when no config file is given' do
      it 'loads the config from config.yml in the project dir' do
        project.configure
        assert_equal './test/tmp', project.config.build_dir
        assert_equal 'debug', project.config.log_level
      end
    end
  end

  describe '#setup_logger!' do
    describe 'log file' do
      before do
        project.configure { |config| config.build_dir = build_path.to_s }
        project.setup_logger!
      end

      it 'sets up a log file in the build directory' do
        log_message = 'testing testing testing'
        log_file = build_path.join('build.log')

        out, err = capture_subprocess_io do
          NerdPress::Logger.instance.info log_message
        end

        assert_match(/#{log_message}/, out)
        assert_empty err
        assert log_file.exist?, 'Expected log file to exist'
      end
    end

    describe 'log level' do
      it 'sets the log level according to the configuration' do
        project.configure do |config|
          config.log_level = :info
        end

        project.setup_logger!
        assert_equal Logger::INFO, NerdPress::Logger.instance.level
      end

      describe 'when log level not configured' do
        it 'uses the default log level (DEBUG)' do
          project.configure
          project.setup_logger!
          assert_equal Logger::DEBUG, NerdPress::Logger.instance.level
        end
      end
    end
  end
end
