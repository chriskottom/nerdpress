require 'test_helper'

describe NerdPress::Commands::Build do
  include CommandHelpers

  let(:formats) { %w( all ) }
  let(:config)  { config_file.to_s }
  let(:version) { '1.2.3' }
  let(:date)    { '2017-07-03' }
  let(:options) {
    { 'config_file' => config, 'version' => version, 'date' => date }
  }

  describe 'banner' do
    it 'formats the banner message correctly' do
      assert_match(/ build \[FORMATS\] \[OPTIONS\]$/,
                   NerdPress::Commands::Build.banner)
    end
  end

  describe 'arguments' do
    it 'takes format arguments' do
      formats = %w(pdf epub mobi)
      command = NerdPress::Commands::Build.new(formats)
      assert_equal formats, command.formats
    end

    it 'defaults to all formats' do
      command = NerdPress::Commands::Build.new
      assert_equal NerdPress::Formats::SUPPORTED_FORMATS, command.formats
    end
  end

  describe 'options' do
    it 'accepts supported options' do
      command = NerdPress::Commands::Build.new([], options)
      assert_equal options, command.options
    end

    it 'uses default values for options not supplied' do
      command = NerdPress::Commands::Build.new
      assert_equal %w(date version), command.options.keys.sort
      assert_nil command.options['config_file']
    end
  end

  describe '#formats' do
    it 'lowercases the formats' do
      formats = %w(PDF HTML)
      command = NerdPress::Commands::Build.new(formats, options)
      assert_equal %w(pdf html), command.formats
    end

    it 'filters out unsupported formats' do
      formats = %w(pdf paper html)
      command = NerdPress::Commands::Build.new(formats, options)
      assert_equal %w(pdf html), command.formats
    end

    it 'defaults to all supported formats' do
      command = NerdPress::Commands::Build.new([], options)
      assert_equal NerdPress::Formats::SUPPORTED_FORMATS, command.formats

      command = NerdPress::Commands::Build.new(['all'], options)
      assert_equal NerdPress::Formats::SUPPORTED_FORMATS, command.formats
    end
  end

  describe '#setup_build' do
    it 'creates the log file' do
      log_path = build_path.join('build.log')
      refute log_path.exist?, 'Expected log file not to exist'

      capture_subprocess_io do
        command = NerdPress::Commands::Build.new(formats, options)
        invoke_tasks(command, :setup_build)
      end

      assert log_path.exist?, 'Expected log file to exist'
    end

    it 'incorporates command line arguments into the configuration' do
      out, err = capture_subprocess_io do
        command = NerdPress::Commands::Build.new(formats, options)
        command.invoke :setup_build
      end

      assert_match(/Exporting version #{ version }/, out)
      assert_match(/Exported file will be published on #{ date }/, out)
      assert_empty err
    end

    it 'sets up the import directory for Images' do
      out, err = capture_subprocess_io do
        command = NerdPress::Commands::Build.new(formats, options)
        command.invoke :setup_build
      end

      expected = Pathname.new('images').expand_path
      assert_equal expected, NerdPress::Image.import_path
      assert_match(/Importing images from #{ expected }/, out)
      assert_empty err
    end
  end

  describe '#export_text' do
    it 'creates the export directory' do
      refute section_export_path.exist?, 'Expected section dir not to exist'

      out, err = capture_subprocess_io do
        command = NerdPress::Commands::Build.new(formats, options)
        invoke_tasks(command, :setup_build, :export_text)
      end

      assert section_export_path.exist?, 'Expected section dir to exist'
    end

    it 'exports each Section as HTML' do
      sections = NerdPress::Section.load_from_directory(section_import_path,
                                                        section_export_path)

      out, err = capture_subprocess_io do
        command = NerdPress::Commands::Build.new(formats, options)
        invoke_tasks(command, :setup_build, :export_text)
      end

      sections.each do |section|
        path = section.export_path
        assert path.exist?, "Expected section to be exported to #{ path }"
        assert_equal section.to_html, path.read
      end
    end
  end

  describe '#export_stylesheets' do
    it 'creates the export directory' do
      refute stylesheet_export_path.exist?, 'Expected stylesheets dir not to exist'

      out, err = capture_subprocess_io do
        command = NerdPress::Commands::Build.new(formats, options)
        invoke_tasks(command, :setup_build, :export_stylesheets)
      end

      assert stylesheet_export_path.exist?, 'Expected stylesheet dir to exist'
    end

    it 'exports each Stylesheet as CSS' do
      import_path, export_path = stylesheet_import_path, stylesheet_export_path
      stylesheets = NerdPress::Stylesheet.load_from_directory(import_path,
                                                              export_path)

      out, err = capture_subprocess_io do
        command = NerdPress::Commands::Build.new(formats, options)
        invoke_tasks(command, :setup_build, :export_stylesheets)
      end

      stylesheets.each do |stylesheet|
        path = stylesheet.export_path
        assert path.exist?, "Expected stylesheet to be exported to #{ path }"
        assert_equal stylesheet.to_css, path.read
      end
    end
  end
end
