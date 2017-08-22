module NerdPress::Processors
  class DummyProcessor
    include NerdPress::Processor
    def process; end
  end

  class FakeProcessor
    include NerdPress::Processor
    def process; end
  end
end
