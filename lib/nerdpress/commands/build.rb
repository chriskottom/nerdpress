require 'thor'
require 'date'

class NerdPress::Commands::Build < Thor::Group
  include Thor::Actions
  include NerdPress::Formats
  include NerdPress::Logging

  desc <<~HEREDOC
  Description:
    The 'nerdpress build' command builds the project in one or more export
    formats. Supported values include: 'all' (default), 'html', 'pdf', 'epub',
    and 'mobi'.

  Examples:
    nerdpress build pdf epub
  HEREDOC

  argument :formats,
           desc: 'Build formats',
           required: false,
           type: :array,
           default: [ NerdPress::Formats::ALL_FORMAT ],
           banner: 'FORMATS'

  class_option :config_file,
               aliases: '-c',
               type: :string,
               default: nil,
               desc: 'Path to configuration file'

  class_option :version,
               aliases: '-V',
               type: :string,
               default: 'x.y.z',
               desc: 'Version string for this export'

  class_option :date,
               aliases: '-d',
               type: :string,
               default: Date.today.strftime('%Y-%m-%d'),
               desc: 'The publication date in any parsable format'

  def self.banner
    "#{basename} build [FORMATS] [OPTIONS]"
  end

  def setup_build
    @project = NerdPress::Project.new
    @project.configure(options[:config_file]) do |config|
      @project.setup_logger!
      info '~~ SETTING UP BUILD ~~'

      config.version = options[:version]
      info "Exporting version #{ config.version }"

      config.publication_date = options[:date]
      info "Exported file will be published on #{ config.publication_date }"
    end

    @project.setup_image_import!
    debug "Images will be imported from #{ NerdPress::Image.import_path }"

    @project.setup_processors!
    proc_names = NerdPress::Processors.processors.map(&:name).join(', ')
    debug "Configured classes for HTML transformation: #{ proc_names }"
  end

  def export_text
    info '~~ EXPORTING TEXT SECTIONS TO HTML ~~'

    @project.export_sections! do |section|
      info "Exported section to #{ section.export_path }"
    end
  end

  def export_stylesheets
    @project.export_stylesheets! do |stylesheet|
      info "Exported to #{ stylesheet.export_path }"
    end
  end

  # Methods that should not be considered Thor commands for invocation
  no_commands do
    alias_method :old_formats, :formats

    def formats
      if !defined?(@normalized_formats)
        @normalized_formats = old_formats.map { |f| f.downcase }
        if @normalized_formats.empty? ||
           @normalized_formats.include?(ALL_FORMAT)
          @normalized_formats.replace SUPPORTED_FORMATS
        end
        @normalized_formats.select! { |f| SUPPORTED_FORMATS.include?(f) }
      end

      @normalized_formats
    end
  end
end
