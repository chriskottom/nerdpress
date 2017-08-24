require 'pathname'
require 'sass'

class NerdPress::Stylesheet
  CSS_EXTENSIONS = %w( css )
  SASS_EXTENSIONS = %w( sass scss )
  STYLESHEET_EXTENSIONS = CSS_EXTENSIONS + SASS_EXTENSIONS
  EXTENSIONS_GLOB = "*.{#{ STYLESHEET_EXTENSIONS.join(',') }}"

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
    @export_dir_path.join(css_filename)
  end

  def to_css
    return export_path.read if exported? && export_path.exist?

    result = @source_path.read
    result = sass_to_css(result)  # used for all formats to compress whitespace
    result
  end

  def export_css!
    @export_dir_path.mkpath unless @export_dir_path.exist?
    export_path.delete if export_path.exist?
    export_path.write self.to_css
    @exported = true
  end

  def exported?
    !!@exported
  end

  private

  def css_filename
    "#{ @source_path.basename('.*') }.css"
  end

  def syntax
    extension = @source_path.extname.sub(/^\./, '')
    extension == 'css' ? 'scss' : extension
  end

  def sass_to_css(style_str)
    Sass::Engine.new(style_str, syntax: syntax.to_sym, style: :compact).render
  end
end
