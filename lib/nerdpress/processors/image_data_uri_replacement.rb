require 'base64'
require 'nokogiri'

class NerdPress::Processors::ImageDataURIReplacement
  include NerdPress::Processor

  def process
    doc = Nokogiri::HTML.fragment(input)
    doc.css('img').each do |img_tag|
      src = img_tag[:src]
      image = NerdPress::Image.lookup(src)
      img_tag[:src] = image.to_data_uri
    end
    doc.to_html
  end
end
