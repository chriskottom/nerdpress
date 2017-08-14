require 'test_helper'

describe NerdPress::Commands::NewProject do
  describe 'banner' do
    it 'formats the banner message correctly' do
      assert_match(/ new PATH$/, klass.banner)
    end
  end

  describe 'arguments' do
    it 'takes a directory argument' do
      directory = 'path/to/my/ebook_project'
      command = klass.new([directory])
      assert_equal directory, command.path
    end

    it 'raises an exception unless directory is provided' do
      err = assert_raises Thor::RequiredArgumentMissingError do
        klass.new
      end

      assert_equal "No value provided for required arguments 'path'", err.message
    end
  end

  describe 'source_root' do
    it 'returns the templates directory' do
      expected = File.expand_path('./lib/nerdpress/templates')
      assert_equal expected, klass.source_root
    end
  end

  describe '#create_project' do
    let(:path) { build_path }

    it 'creates a skeleton project' do
      capture_subprocess_io do
        command = klass.new([ path.to_s ], {})
        command.invoke :create_project
      end

      assert path.exist?, 'Expected new project to be created'

      config_path = path.join('Gemfile')
      assert config_path.exist?, 'Expected Gemfile to be created'

      config_path = path.join('config.yml')
      assert config_path.exist?, 'Expected config file to be created'

      sections_path = path.join('sections')
      assert sections_path.directory?, 'Expected sections/ dir to be created'

      images_path = path.join('images')
      assert images_path.directory?, 'Expected images/ dir to be created'

      styles_path = path.join('stylesheets')
      assert styles_path.directory?, 'Expected stylesheets/ dir to be created'
    end
  end

  private

  def klass
    NerdPress::Commands::NewProject
  end
end
