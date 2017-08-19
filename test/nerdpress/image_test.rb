require 'test_helper'

describe NerdPress::Image do
  let(:image_source) { project_path.join('images/blue-square.png') }
  let(:bad_image_source) { project_path.join('images/red-square.png') }

  before do
    klass.instances = nil
  end

  describe 'lookup' do
    it 'returns the Image for the image file at the given path' do
      relative_path = 'images/blue-square.png'
      image = klass.lookup(relative_path, project_path)
      assert_equal image_source.expand_path, image.source_path
    end

    it 'raises an error if the given image path does not exist' do
      relative_path = 'images/red-square.png'
      error = assert_raises ArgumentError do
        klass.lookup(relative_path, project_path)
      end

      assert_match %r{^File not found at .*#{ relative_path }}, error.message
    end
  end

  describe 'constructor' do
    it 'sets the source path' do
      image = klass.new(image_source)
      assert_equal Pathname.new(image_source).expand_path, image.source_path
    end

    it 'adds the new instance to the registry of instances' do
      image = klass.new(image_source)
      path = Pathname.new(image_source).expand_path
      assert_equal image, klass.instances[path]
    end
  end

  describe '#==' do
    it 'tests equality via absolute source path' do
      path1 = 'test/fixtures/project/images/blue-square.png'
      path2 = File.dirname(__FILE__) +
              '/../fixtures/project/images/blue-square.png'
      assert_equal klass.new(path1), klass.new(path2)

      refute_equal klass.new(path1), klass.new(bad_image_source)
    end
  end

  describe '#to_data_uri' do
    it 'produces a data URI based on the image file' do
      image = klass.new(image_source)
      assert_match %r{^data:image/png;base64,}, image.to_data_uri

      base64_encoded_content = Base64.encode64(image.source_path.read)
      base64_encoded_content.gsub!("\n", '')
      assert_match /base64,#{ base64_encoded_content }$/, image.to_data_uri
    end
  end

  private

  def klass
    NerdPress::Image
  end
end
