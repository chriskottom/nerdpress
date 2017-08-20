require 'test_helper'

describe NerdPress::Image do
  let(:image_source) { project_path.join('images/blue-square.png') }
  let(:bad_image_source) { project_path.join('images/red-square.png') }

  before do
    klass.instances = nil
  end

  describe 'lookup' do
    before do
      NerdPress::Image.import_path = image_import_path
    end

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

  describe 'compute_absolute_path' do
    it 'returns the absolute path for a relative image path if found' do
      image_filename = 'images/blue-square.png'
      import_path = image_import_path

      assert_equal image_source.expand_path,
                   klass.compute_absolute_path(image_filename, import_path)
    end

    it 'returns nil if no matching file is found' do
      image_filename = 'images/green-square.png'
      import_path = image_import_path

      assert_nil klass.compute_absolute_path(image_filename, import_path)
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
    describe 'when source is PNG' do
      it 'produces a data URI based on the image file' do
        image = klass.new(image_source)
        content = Base64.encode64(image_source.read).gsub("\n", '')
        assert_data_uri(image, mime_type: 'image/png', content: content)
      end
    end

    describe 'when source is JPEG' do
      it 'produces a data URI based on the image file' do
        image_path = project_path.join('images/avatar.jpg')
        image = klass.new(image_path)
        content = Base64.encode64(image_path.read).gsub("\n", '')
        assert_data_uri(image, mime_type: 'image/jpeg', content: content)

        image_path = project_path.join('images/avatar.jpeg')
        image = klass.new(image_path)
        content = Base64.encode64(image_path.read).gsub("\n", '')
        assert_data_uri(image, mime_type: 'image/jpeg', content: content)
      end
    end

    describe 'when source is SVG' do
      it 'produces a data URI based on the image file' do
        image_path = project_path.join('images/exit-icon.svg')
        image = klass.new(image_path)
        content = Base64.encode64(image_path.read).gsub("\n", '')
        assert_data_uri(image, mime_type: 'image/svg+xml', content: content)
      end
    end

    describe 'when source is GIF' do
      it 'produces a data URI based on the image file' do
        image_path = project_path.join('images/guy.gif')
        image = klass.new(image_path)
        content = Base64.encode64(image_path.read).gsub("\n", '')
        assert_data_uri(image, mime_type: 'image/gif', content: content)
      end
    end
  end

  private

  def klass
    NerdPress::Image
  end

  def assert_data_uri(image, mime_type: nil, content: nil)
    data_uri = image.to_data_uri

    if mime_type
      escape_for_regexp(mime_type)
      assert_match %r{^data:#{ mime_type };base64,}, data_uri
    end

    if content
      escape_for_regexp(content)
      assert_match %r{base64,#{ content }$}, data_uri
    end
  end

  def escape_for_regexp(string)
    string.gsub!(/\//, '\\/')
    string.gsub!(/\+/, '\\\\+')
  end
end
