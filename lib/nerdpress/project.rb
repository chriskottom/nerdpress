require 'pathname'

require_relative './configuration.rb'
require_relative './section.rb'
require_relative './stylesheet.rb'
require_relative './image.rb'
require_relative './manuscript.rb'

class NerdPress::Project
  attr_reader :home_directory, :configuration
  alias_method :config, :configuration

  def initialize(home_dir = Dir.getwd)
    @home_directory = Pathname.new(home_dir).expand_path
    raise ArgumentError, 'Path does not exist' unless @home_directory.exist?
  end

  def configure(config_file = nil)
    config_file ||= home_directory.join('config.yml')
    @configuration = NerdPress::Configuration.load(config_file)
    yield @configuration if block_given?
    @configuration
  end

  def setup_logger!
    NerdPress::Logger.setup(log_dir: build_path, log_level: log_level)
  end

  def setup_image_import!
    NerdPress::Image.setup_import_path image_import_path
  end

  def setup_processors!
    if processors = config_value(:processors)
      NerdPress::Processors.setup_processors processors
    end
  end

  def export_sections!
    sections.each do |section|
      section.export_html!
      yield section if block_given?
    end
  end

  def export_stylesheets!
    Sass.load_paths << stylesheet_import_path
    stylesheets.each do |stylesheet|
      stylesheet.export_css!
      yield stylesheet if block_given?
    end
  end

  def export_manuscript!(format)
    validate_export_format(format)
    manuscript = manuscript_for(format)
    manuscript.export_html!
    yield manuscript if block_given?
  end

  private

  def config_value(sym)
    (config && config.send(sym)) || nil
  end

  def validate_export_format(format)
    if !NerdPress::Formats::SUPPORTED_FORMATS.include?(format)
      raise NerdPress::UnsupportedFormat, "Unsupported format: #{ format }"
    end
  end

  def build_path
    @build_dir ||= config_value(:build_dir) || home_directory.join('build')
    Pathname.new(@build_dir)
  end

  def log_level
    config_value(:log_level) || NerdPress::Logger::DEFAULT_LEVEL
  end

  def section_import_path
    @sections_dir ||= ( config_value(:sections_dir) ||
                        home_directory.join('sections') )
    Pathname.new(@sections_dir)
  end

  def section_export_path
    build_path.join('sections')
  end

  def sections
    if !@sections
      @sections = sections_list_from_config
      @sections ||= NerdPress::Section.load_from_directory(section_import_path,
                                                           section_export_path)
    end

    @sections
  end

  def sections_list_from_config
    locations = config_value(:sections)
    if locations
      locations.map do |location|
        NerdPress::Section.new(location, section_export_path)
      end
    end
  end

  def stylesheet_import_path
    @stylesheets_dir ||= ( config_value(:stylesheets_dir) ||
                           home_directory.join('stylesheets') )
    Pathname.new(@stylesheets_dir)
  end

  def stylesheet_export_path
    build_path.join('stylesheets')
  end

  def stylesheets
    if !@stylesheets
      import_path = stylesheet_import_path
      export_path = stylesheet_export_path
      @stylesheets = NerdPress::Stylesheet.load_from_directory(import_path,
                                                               export_path)
    end

    @stylesheets
  end

  def stylesheet_for(format)
    case format
    when 'html', 'pdf', 'mobi', 'epub'
      stylesheet = stylesheets.find do |s|
        s.export_path.basename.to_s == "#{ format }.css"
      end

      if !stylesheet
        raise NerdPress::StylesheetMissing,
              "Styles not found for format: #{ format }"
      else
        stylesheet
      end
    end
  end

  def image_import_path
    @image_dir ||= ( config_value(:image_dir) ||
                     home_directory.join('images') )
    Pathname.new(@image_dir)
  end

  def manuscripts
    @manuscripts ||= {}
  end

  def manuscript_for(format)
    manuscripts[format] ||= NerdPress::Manuscript.new(format: format,
                                                      export_dir: build_path,
                                                      sections: sections,
                                                      stylesheet: stylesheet_for(format))
  end
end
