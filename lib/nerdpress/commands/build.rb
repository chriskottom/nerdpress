require 'thor'
require 'date'

class NerdPress::Commands::Build < Thor::Group
  include Thor::Actions

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
end
