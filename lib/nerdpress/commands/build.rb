require 'thor'
require 'date'

class NerdPress::Commands::Build < Thor::Group
  include Thor::Actions

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

      config.version = options[:version]
      info "Exporting version #{ config.version }"

      config.publication_date = options[:date]
      info "Exported file will be published on #{ config.publication_date }"
    end
  end
end
