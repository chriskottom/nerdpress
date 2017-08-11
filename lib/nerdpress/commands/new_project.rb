require 'thor'

class NerdPress::Commands::NewProject < Thor::Group
  include Thor::Actions

  desc <<~HEREDOC
  Description:
    The 'nerdpress new' command creates a new NerdPress project with a
    default directory structure and configuration at a path you specify.

  Example:
    nerdpress new ~/projects/new_ebook
  HEREDOC

  argument :path,
           desc: 'Path to the new project folder',
           required: true,
           type: :string,
           banner: 'PATH'

  def self.banner
    "#{basename} new PATH"
  end
end
