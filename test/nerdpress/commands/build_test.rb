require 'test_helper'

describe NerdPress::Commands::Build do
  let(:formats) { %w( all ) }
  let(:config)  { './test/fixtures/project/config.yml' }
  let(:version) { '1.2.3' }
  let(:date)    { '2017-07-03' }
  let(:options) {
    { 'config_file' => config, 'version' => version, 'date' => date }
  }

  describe 'banner' do
    it 'formats the banner message correctly' do
      assert_match(/ build \[FORMATS\] \[OPTIONS\]$/,
                   NerdPress::Commands::Build.banner)
    end
  end

  describe 'arguments' do
    it 'takes format arguments' do
      formats = %w(pdf epub mobi)
      command = NerdPress::Commands::Build.new(formats)
      assert_equal formats, command.formats
    end

    it 'defaults to all formats' do
      command = NerdPress::Commands::Build.new
      assert_equal [ NerdPress::Formats::ALL_FORMAT ], command.formats
    end
  end

  describe 'options' do
    it 'accepts supported options' do
      command = NerdPress::Commands::Build.new([], options)
      assert_equal options, command.options
    end

    it 'uses default values for options not supplied' do
      command = NerdPress::Commands::Build.new
      assert_equal %w(date version), command.options.keys.sort
      assert_nil command.options['config_file']
    end
  end
end
