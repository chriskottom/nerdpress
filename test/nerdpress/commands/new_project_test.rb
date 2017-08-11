require 'test_helper'

describe NerdPress::Commands::NewProject do
  describe 'banner' do
    it 'formats the banner message correctly' do
      assert_match(/ new PATH$/, klass.banner)
    end
  end

  describe 'arguments' do
    it 'takes a directory argument' do
      directory = 'path/to/my/ebook_project'
      command = klass.new([directory])
      assert_equal directory, command.path
    end

    it 'raises an exception unless directory is provided' do
      err = assert_raises Thor::RequiredArgumentMissingError do
        klass.new
      end

      assert_equal "No value provided for required arguments 'path'", err.message
    end
  end

  private

  def klass
    NerdPress::Commands::NewProject
  end
end
