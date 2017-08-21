require 'test_helper'

describe NerdPress::Processors::ImageDataURIReplacement do
  let(:image_path) { 'images/blue-square.png' }
  let(:image_url) { 'http://google.com/logo.png' }
  let(:local_source_html) { "<img src='#{ image_path }'>" }
  let(:remote_source_html) { "<img src=\"#{ image_url }\">" }
  let(:processor) { NerdPress::Processors::ImageDataURIReplacement }

  before do
    NerdPress::Image.setup_import_path image_import_path
  end

  it 'replaces local image sources with data URIs' do
    assert_match %r{<img src="data:image/png;base64,.*},
                 processor.process(local_source_html)
  end

  it 'leaves sources not found locally as they are' do
    out, err = capture_subprocess_io do
      assert_equal remote_source_html, processor.process(remote_source_html)
    end
  end
end
