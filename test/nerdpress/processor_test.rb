require 'test_helper'

class NerdPress::Processors::DummyProcessor
  include NerdPress::Processor
  def process; end
end

describe NerdPress::Processors do
  describe 'processors' do
    describe 'when set up with an array of Processor class names' do
      it 'updates the set of Processors' do
        proc_names = %w(NerdPress::Processors::DummyProcessor)
        klass.setup_processors proc_names

        assert_equal [NerdPress::Processors::DummyProcessor], klass.processors
      end

      describe 'when set up with a blank array of Processor class names' do
        it 'uses the default set of Processors' do
          klass.setup_processors
          assert_equal klass.default_processors, klass.processors
        end
      end
    end
  end

  private

  def klass
    NerdPress::Processors
  end
end
