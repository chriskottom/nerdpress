require 'fileutils'

module BuildHelpers
  BUILD_DIR = './test/tmp'
  CONFIG_FILE = './test/fixtures/project/config.yml'

  def build_path
    @build_path ||= Pathname.new(BUILD_DIR)
  end

  def config_file
    @config_file ||= Pathname.new(CONFIG_FILE)
  end

  def reset_build
    project.instance_variable_set(:@configuration, nil) if defined?(project)
    build_path.rmtree if build_path.exist?
  end
end
