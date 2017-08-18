require 'test_helper'

describe NerdPress::Stylesheet do
  let(:export_path) { stylesheet_export_path }
  let(:css_source) { File.join(stylesheet_import_path, 'pdf.css') }
  let(:sass_source) { File.join(stylesheet_import_path, 'mobi.sass') }
  let(:scss_source) { File.join(stylesheet_import_path, 'epub.scss') }
  let(:css_stylesheet) { klass.new(css_source, stylesheet_export_path) }
  let(:sass_stylesheet) { klass.new(sass_source, stylesheet_export_path) }
  let(:scss_stylesheet) { klass.new(scss_source, stylesheet_export_path) }
  let(:expected_css) { File.read(css_source) }

  describe 'load_from_directory' do
    it 'returns an Array of Stylesheet objects for files in that directory' do
      stylesheets = klass.load_from_directory(stylesheet_import_path,
                                              export_path)
      assert_equal [scss_stylesheet, sass_stylesheet, css_stylesheet],
                   stylesheets
    end

    it 'sorts the Stylesheets by filename' do
      stylesheets = klass.load_from_directory(stylesheet_import_path,
                                              export_path)
      assert_equal %w(epub.scss mobi.sass pdf.css),
                   stylesheets.map {|s| s.source_path.basename.to_s }
    end

    it 'raises an error if the directory does not exist' do
      dirname = './not/a/real/directory'
      error = assert_raises(ArgumentError) do
        klass.load_from_directory(dirname, nil)
      end

      assert_match /^Directory does not exist/, error.message
    end
  end

  describe 'constructor' do
    it 'sets the source path' do
      expected = File.expand_path(css_source)
      assert_equal expected, css_stylesheet.source_path.to_s
    end

    it 'sets the export directory' do
      basename = File.basename(css_source)
      expected = "#{ export_path.expand_path }/#{ basename }"
      assert_equal expected, css_stylesheet.export_path.to_s
    end
  end

  describe '#==' do
    it 'tests equality via absolute source path' do
      path1 = 'test/fixtures/project/stylesheets/pdf.css'
      path2 = File.dirname(__FILE__) +
              '/../fixtures/project/stylesheets/pdf.css'
      assert_equal klass.new(path1, export_path), klass.new(path2, export_path)

      path3 = 'test/fixtures/stylesheets/mobi.sass'
      refute_equal klass.new(path1, export_path), klass.new(path3, export_path)
    end
  end

  describe '#export_path' do
    it 'appends the proper CSS filename to the export directory path' do
      expected = export_path.join('pdf.css').expand_path
      assert_equal expected, css_stylesheet.export_path
    end
  end

  describe '#to_css' do
    describe 'when source is CSS' do
      it 'returns the source without modification' do
        assert_equal expected_css, css_stylesheet.to_css
      end
    end

    describe 'when source is Sass' do
      it 'returns compiled CSS' do
        assert_equal expected_css, sass_stylesheet.to_css
      end
    end

    describe 'when source is SCSS' do
      it 'returns compiled CSS' do
        assert_equal expected_css, scss_stylesheet.to_css
      end
    end
  end

  describe '#export_css!' do
    it 'writes the CSS to the designated export directory' do
      refute scss_stylesheet.export_path.exist?,
             'Expected stylesheet not to be exported'

      scss_stylesheet.export_css!

      assert scss_stylesheet.export_path.exist?,
             'Expected stylesheet to be exported'
      assert_equal expected_css, scss_stylesheet.export_path.read
    end
  end

  private

  def klass
    NerdPress::Stylesheet
  end
end
