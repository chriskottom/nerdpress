require 'pathname'
require 'base64'

class NerdPress::Image
  attr_reader :source_path

  class << self
    attr_writer :instances

    def instances
      @instances ||= {}
    end

    def lookup(path, dir = image_import_path)
      path = Pathname.new(dir).join(path).expand_path
      raise ArgumentError, "File not found at #{ path }" unless path.exist?
      return instances[path] if instances.has_key?(path)

      instances[path] = new(path)
    end
  end

  def initialize(path)
    @source_path = Pathname.new(path).expand_path
    self.class.instances[@source_path] = self
  end

  def ==(other)
    self.source_path.expand_path == other.source_path.expand_path
  end

  def to_data_uri
    content = @source_path.read
    encoded = Base64.encode64(content).gsub("\n", '')
    "data:#{ mime_type };base64,#{ encoded }"
  end

  private

  def suffix
    @source_path.extname.sub(/^\./, '')
  end

  def mime_type
    case suffix
    when 'jpg', 'jpeg'
      'image/jpeg'
    when 'svg'
      'image/svg+xml'
    else
      "image/#{ suffix }"
    end
  end
end
