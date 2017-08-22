require 'test_helper'

describe NerdPress::Project do
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

  describe '#setup_image_import!' do
    after do
      NerdPress::Image.setup_import_path nil
    end

    describe 'when defined in the config' do
      it 'sets the import path for Images according to the config' do
        image_dir = './test/images'
        project.configure do |config|
          config.image_dir = image_dir
        end

        project.setup_image_import!

        assert_equal Pathname.new(image_dir).expand_path,
                     NerdPress::Image.import_path
      end
    end

    describe 'when not defined in the config' do
      it 'sets the import path for Images to a default value' do
        project.configure
        project.setup_image_import!

        assert_equal image_import_path.expand_path, NerdPress::Image.import_path
      end
    end
  end

  describe '#setup_processors!' do
    describe 'when defined in the config' do
      let(:processor_names) { %w( NerdPress::Processors::DummyProcessor
                                  NerdPress::Processors::FakeProcessor ) }
      let(:processors) { [ NerdPress::Processors::DummyProcessor,
                           NerdPress::Processors::FakeProcessor ] }

      it 'uses the requested Processor classes' do
        project.configure do |config|
          config.processors = processor_names
        end
        project.setup_processors!

        assert_equal processors, NerdPress::Processors.processors
      end
    end

    describe 'when not defined in the config' do
      it 'uses the default list of Processors' do
        project.configure
        project.setup_processors!

        assert_equal NerdPress::Processors.default_processors,
                     NerdPress::Processors.processors
      end
    end
  end

  describe '#export_sections!' do
    before do
      project.configure
    end

    it 'creates an HTML export folder in the build directory' do
      refute section_export_path.exist?, 'Expected section dir not to exist'

      project.export_sections!
      assert section_export_path.exist?, 'Expected section dir to exist'
    end

    it 'writes HTML for each section to an export file' do
      sections = NerdPress::Section.load_from_directory(section_import_path,
                                                        section_export_path)
      project.export_sections!

      sections.each do |section|
        path = section.export_path
        assert path.exist?, "Expected section to be exported to #{ path }"
        assert_equal section.to_html, path.read
      end
    end

    describe 'when sections are explicitly listed in the config file' do
      before do
        config_file = './test/fixtures/config_with_sections.yml'
        project.configure(config_file)
      end

      it 'exports the Sections in the order listed' do
        source_paths = []
        project.export_sections! do |section|
          source_paths << section.source_path
        end

        assert_equal 2, source_paths.size
        assert_match %r{/section2\.md}, source_paths[0].to_s
        assert_match %r{/section1\.html}, source_paths[1].to_s
      end
    end
  end

  describe '#export_stylesheets!' do
    before do
      project.configure
    end

    it 'creates a CSS export folder in the build directory' do
      refute stylesheet_export_path.exist?, 'Expected stylesheet dir not to exist'

      project.export_stylesheets!
      assert stylesheet_export_path.exist?, 'Expected stylesheet dir to exist'
    end

    it 'writes CSS for each stylesheet to an export file' do
      import_path, export_path = stylesheet_import_path, stylesheet_export_path
      stylesheets = NerdPress::Stylesheet.load_from_directory(import_path,
                                                              export_path)
      project.export_stylesheets!

      stylesheets.each do |stylesheet|
        path = stylesheet.export_path
        assert path.exist?, "Expected stylesheet to be exported to #{ path }"
        assert_equal stylesheet.to_css, path.read
      end
    end
  end
end
