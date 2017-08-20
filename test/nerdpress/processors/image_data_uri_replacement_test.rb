require 'test_helper'

describe NerdPress::Processors::ImageDataURIReplacement do
  let(:image_path) { 'images/blue-square.png' }
  let(:input_html) { "<img src='#{ image_path }'/>" }
  let(:processor) { NerdPress::Processors::ImageDataURIReplacement }

  before do
    NerdPress::Image.import_path = image_import_path.expand_path
  end

  it 'replaces path-based image sources with data URIs' do
    assert_match %r{<img src="data:image/png;base64,.*},
                 processor.process(input_html)
  end
end
