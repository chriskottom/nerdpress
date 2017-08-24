require 'test_helper'

describe NerdPress::Section do
  let(:import_dir) { './test/fixtures/project/sections' }
  let(:export_dir) { './test/tmp/sections' }
  let(:html_source) { File.join(import_dir, 'section1.html') }
  let(:markdown_source) { File.join(import_dir, 'section2.md') }
  let(:html_section) { klass.new(html_source, export_dir) }
  let(:markdown_section) { klass.new(markdown_source, export_dir) }

  describe 'load_from_directory' do
    it 'returns an Array of Section objects for files in that directory' do
      sections = klass.load_from_directory(import_dir, export_dir)
      assert_equal [html_section, markdown_section], sections
    end

    it 'sorts the Sections by filename' do
      sections = klass.load_from_directory(import_dir, export_dir)

      expected_names = %w(section1.html section2.md)
      actual_names = sections.map {|s| s.source_path.basename.to_s }
      assert_equal expected_names, actual_names
    end

    it 'raises an error if the directory does not exist' do
      dirname = './not/a/real/directory'
      error = assert_raises(ArgumentError) do
        klass.load_from_directory(dirname, export_dir)
      end

      assert_match /^Directory does not exist/, error.message
    end
  end

  describe 'constructor' do
    it 'sets the source path' do
      expected = File.expand_path(markdown_source)
      assert_equal expected, markdown_section.source_path.to_s
    end

    it 'sets the export directory' do
      expected = File.expand_path(html_source)
      assert_match /^#{ expected }/, html_section.source_path.to_s
    end
  end

  describe '#==' do
    it 'tests equality via absolute source path' do
      path1 = 'test/fixtures/project/sections/section1.html'
      path2 = File.dirname(__FILE__) +
              '/../fixtures/project/sections/section1.html'
      assert_equal klass.new(path1, export_dir), klass.new(path2, export_dir)

      path3 = 'test/fixtures/sections/section1.html'
      refute_equal klass.new(path1, export_dir), klass.new(path3, export_dir)
    end
  end

  describe '#export_path' do
    it 'appends the proper HTML filename to the export directory path' do
      expected = Pathname.new(export_dir).join('section2.html').expand_path
      assert_equal expected, markdown_section.export_path
    end
  end

  describe '#basename' do
    it 'returns the export filename' do
      assert_equal 'section2.html', markdown_section.basename
    end
  end

  describe '#to_html' do
    let(:comment_text) { '<!-- PREVIOUSLY EXPORTED CONTENT -->' }

    it 'applies the default processor chain' do
      html = File.read(html_source)
      mock1 = mock_processor(html, html_section)
      mock2 = mock_processor(html, html_section)

      NerdPress::Processors.stub(:default_processors, [mock1, mock2]) do
        html_section.to_html
      end

      assert_mock mock1
      assert_mock mock2
    end

    describe 'when the Section has not been exported' do
      it 'generates the HTML from scratch' do
        refute_match comment_text, markdown_section.to_html
      end
    end

    describe 'when the Section has been exported' do
      before do
        markdown_section.export_html!
        markdown_section.export_path.write comment_text
      end

      it 'reads the HTML content from the exported file' do
        assert_match(/#{ comment_text }$/, markdown_section.to_html)
      end
    end
  end

  describe '#export_html!' do
    describe 'when source is HTML' do
      it 'writes the HTML to the designated export directory' do
        section = html_section
        refute section.export_path.exist?, 'Expected export file not to exist'

        section.export_html!
        assert section.export_path.exist?, 'Expected export file to exist'
        assert_equal section.source_path.read, section.export_path.read
      end

      it 'sets the #exported? flag' do
        refute html_section.exported?, 'Expected Section not to be exported'

        html_section.export_html!
        assert html_section.exported?, 'Expected Section to be exported'
      end
    end

    describe 'when source is Markdown' do
      it 'converts to HTML and writes to the designated export directory' do
        section = markdown_section
        refute section.export_path.exist?, 'Expected export file not to exist'

        section.export_html!
        assert section.export_path.exist?, 'Expected export file to exist'
        assert_equal MarkupHelpers::SAMPLE_HTML, section.export_path.read
      end

      it 'sets the #exported? flag' do
        refute markdown_section.exported?, 'Expected Section not to be exported'

        markdown_section.export_html!
        assert markdown_section.exported?, 'Expected Section to be exported'
      end
    end
  end

  private

  def klass
    NerdPress::Section
  end

  def mock_processor(*args)
    mock = Minitest::Mock.new
    mock.expect(:process, args.first, args)
    mock
  end
end
