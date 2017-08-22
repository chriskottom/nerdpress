require 'pathname'
require 'nokogiri'

class NerdPress::Manuscript
  def initialize(format:, export_dir:, sections: [], stylesheet: nil)
    @format = format
    @export_dir_path = Pathname.new(export_dir)
    @sections = sections
    @stylesheet = stylesheet
  end

  def export_path
    @export_dir_path.join(html_filename).expand_path
  end

  def to_html
    builder= Nokogiri::HTML::Builder.new do |doc|
      doc.html {
        doc.style(type: 'text/css') {
          doc << stylesheet_contents
        }
        doc.body {
          @sections.each do |section|
            section_comment(doc, section)
            doc << section_contents(section)
          end
        }
      }
    end
    builder.to_html
  end

  def export_html!
    @export_dir_path.mkpath unless @export_dir_path.exist?
    export_path.delete if export_path.exist?
    export_path.write self.to_html
  end

  private

  def html_filename
    "manuscript_#{ @format }.html"
  end

  def section_comment(doc, section)
    doc << "\n\n"
    doc.comment section.basename
    doc << "\n"
  end

  def section_contents(section)
    section.to_html
  end

  def stylesheet_contents
    @stylesheet.to_css
  end
end
