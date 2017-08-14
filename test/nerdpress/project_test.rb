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
end
