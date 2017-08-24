require 'test_helper'

describe NerdPress::Manuscript do
  let(:format) { 'pdf' }
  let(:export_dir) { build_path }
  let(:stylesheet_source) { stylesheet_import_path.join('pdf.css') }
  let(:sections) {
    NerdPress::Section.load_from_directory(section_import_path,
                                           section_export_path)
  }
  let(:stylesheet) {
    NerdPress::Stylesheet.new(stylesheet_source, stylesheet_export_path)
  }
  let(:manuscript) {
    klass.new(format: format, export_dir: export_dir,
              sections: sections, stylesheet: stylesheet)
  }

  describe '#export_path' do
    it 'appends the proper HTML filename to the export directory path' do
      expected = Pathname.new(export_dir).join('manuscript_pdf.html').expand_path
      assert_equal expected, manuscript.export_path
    end
  end

  describe '#to_html' do
    let(:html) { manuscript.to_html }
    let(:css) { stylesheet.to_css }
    let(:comment_text) { '<!-- PREVIOUSLY EXPORTED CONTENT -->' }

    it 'formats the collected resources as an HTML document' do
      assert_match(%r{^<!DOCTYPE html .*<html>.*</html>$}m, html)
    end

    it 'includes the Stylesheet CSS in the output' do
      assert_match(%r{<style type=['"]text/css['"]>\s*#{ css }\s*</style>}m, html)
    end

    it 'includes all Section HTML in the output' do
      section_html = sections.map(&:to_html).join('.*')
      assert_match(%r{#{ section_html }}m, html)
    end

    describe 'when the Manuscript has not been exported' do
      it 'generates the HTML document from scratch' do
        refute_match comment_text, manuscript.to_html
      end
    end

    describe 'when the Manuscript has been exported' do
      before do
        manuscript.export_html!
        manuscript.export_path.write comment_text
      end

      it 'reads the HTML content from the exported file' do
        assert_match(/#{ comment_text }$/, manuscript.to_html)
      end
    end
  end

  describe '#export_html!' do
    it 'writes the HTML to the designated export directory' do
      refute manuscript.export_path.exist?, 'Expected export file not to exist'

      manuscript.export_html!
      assert manuscript.export_path.exist?, 'Expected export file to exist'
      assert_equal manuscript.to_html, manuscript.export_path.read
    end

    it 'sets the #exported? flag' do
      refute manuscript.exported?, 'Expected new Manuscript not to be exported'

      manuscript.export_html!
      assert manuscript.exported?, 'Expected Manuscript to be exported'
    end
  end

  private

  def klass
    NerdPress::Manuscript
  end
end
