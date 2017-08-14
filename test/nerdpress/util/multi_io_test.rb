require 'test_helper'

describe MultiIO do
  let(:target1) { Minitest::Mock.new }
  let(:target2) { Minitest::Mock.new }
  let(:target3) { Minitest::Mock.new }
  let(:io)      { MultiIO.new(target1, target2, target3) }

  describe '#write' do
    let(:string) { 'Chunky bacon' }

    before do
      [target1, target2, target3].each do |target|
        target.expect :write, string.bytesize, [string]
      end
    end

    it 'calls write on all targets' do
      io.write string

      assert_mock target1
      assert_mock target2
      assert_mock target3
    end
  end

  describe '#close' do
    before do
      [target1, target2, target3].each do |target|
        target.expect :close, nil
      end
    end

    it 'calls close on all targets' do
      io.close

      assert_mock target1
      assert_mock target2
      assert_mock target3
    end
  end
end
