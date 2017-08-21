module NerdPress::Processor
  def initialize(input_str, section = nil)
    @input = input_str
    @section = section
  end

  def self.included(base)
    base.include(InstanceMethods)
    base.extend(ClassMethods)
  end

  module InstanceMethods
    attr_accessor :input, :section
  end

  module ClassMethods
    def process(*args)
      new(*args).process
    end
  end
end

module NerdPress::Processors
  class << self
    def setup_processors(processor_names = [])
      if processor_names.nil? || processor_names.empty?
        @processors = nil
        return
      end

      @processors = processor_names.map do |proc_name|
        Module.const_get(proc_name)
      end
    end

    def processors
      @processors || default_processors
    end

    def default_processors
      [ NerdPress::Processors::ImageDataURIReplacement ]
    end
  end
end

require_relative './processors/markdown_to_html.rb'
require_relative './processors/image_data_uri_replacement.rb'
