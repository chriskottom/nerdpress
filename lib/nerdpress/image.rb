require 'pathname'
require 'base64'

class NerdPress::Image
  attr_reader :source_path

  class << self
    attr_accessor :import_path
    attr_writer :instances

    def instances
      @instances ||= {}
    end

    def lookup(search_path, dir = import_path)
      image_path = compute_absolute_path(search_path, dir)
      raise ArgumentError, "File not found at #{ search_path }" unless image_path

      return instances[image_path] if instances.has_key?(image_path)

      instances[image_path] = new(image_path)
    end

    def compute_absolute_path(image_path, dir = import_path)
      found_paths = []
      Pathname.new(dir).find do |path|
        found_paths << path if path.to_s =~ /#{ image_path.to_s }$/
      end

      return found_paths.first.expand_path if found_paths.any?
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
