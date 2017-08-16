require 'github/markup'
require 'commonmarker'

class NerdPress::Processors::MarkdownToHTML
  include NerdPress::Processor

  def process
    GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, input)
  end
end
