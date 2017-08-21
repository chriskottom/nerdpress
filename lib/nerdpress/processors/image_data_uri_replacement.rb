require 'base64'
require 'nokogiri'

class NerdPress::Processors::ImageDataURIReplacement
  include NerdPress::Processor
  include NerdPress::Logging

  def process
    doc = Nokogiri::HTML.fragment(input)
    doc.css('img').each do |img_tag|
      src = img_tag[:src]
      begin
        image = NerdPress::Image.lookup(src)
        img_tag[:src] = image.to_data_uri
      rescue ArgumentError => error
        warn "No local image source found: #{ src }"
        warn 'Retaining original souce'
      end
    end
    doc.to_html
  end
end
