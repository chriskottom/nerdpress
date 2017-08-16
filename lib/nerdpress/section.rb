require 'pathname'

class NerdPress::Section
  HTML_EXTENSIONS = %w( html htm xhtml )
  MARKDOWN_EXTENSIONS = %w( markdown mdown mkdn md mkd mdwn )
  EXTENSIONS = HTML_EXTENSIONS + MARKDOWN_EXTENSIONS
  EXTENSIONS_GLOB = "*.{#{ EXTENSIONS.join(',') }}"

  attr_reader :source_path

  def self.load_from_directory(import_dir, export_dir)
    import_path = Pathname.new(import_dir).expand_path
    if !import_path.exist?
      raise ArgumentError, "Directory does not exist: #{ import_path }"
    end

    Dir.glob("#{ import_path.to_s }/#{ EXTENSIONS_GLOB }").sort.map do |file|
      new(file, export_dir)
    end
  end

  def initialize(source_file, export_dir)
    @source_path = Pathname.new(source_file).expand_path
    @export_dir_path = Pathname.new(export_dir).expand_path
  end

  def ==(other)
    self.source_path.expand_path == other.source_path.expand_path
  end

  def export_path
    @export_dir_path.join(html_filename)
  end

  private

  def html_filename
    "#{ @source_path.basename('.*') }.html"
  end
end
