require 'pathname'

require_relative './processor'

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

  def basename
    html_filename
  end

  def to_html
    return export_path.read if exported? && export_path.exist?

    result = source
    processors.each do |processor|
      result = processor.process(result, self)
    end
    result
  end

  def export_html!
    @export_dir_path.mkpath unless @export_dir_path.exist?
    export_path.delete if export_path.exist?
    export_path.write self.to_html
    @exported = true
  end

  def exported?
    !!@exported
  end

  private

  def html_filename
    "#{ @source_path.basename('.*') }.html"
  end

  def source
    @source_path.read
  end

  def markdown?
    extension = @source_path.extname.sub(/^\./, '')
    MARKDOWN_EXTENSIONS.include?(extension)
  end

  def processors
    proc_chain = []
    proc_chain << NerdPress::Processors::MarkdownToHTML if markdown?
    proc_chain += NerdPress::Processors.default_processors
    proc_chain
  end
end
