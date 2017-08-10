require 'test_helper'

describe NerdPress::Project do
  describe '#initialize' do
    it 'sets the home directory' do
      home_dir = './test/fixtures/project'
      project = NerdPress::Project.new(home_dir)
      assert_equal Pathname.new(home_dir).expand_path, project.home_directory
    end

    it 'fails when given a nonexistent directory' do
      err = assert_raises ArgumentError do
        NerdPress::Project.new('/path/does/not/exist')
      end

      assert_equal 'Path does not exist', err.message
    end
  end
end
