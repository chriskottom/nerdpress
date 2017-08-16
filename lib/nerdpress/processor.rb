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
  def self.default_processors
    [ ]
  end
end
