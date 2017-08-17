require 'fileutils'

module BuildHelpers
  BUILD_DIR = './test/tmp'
  PROJECT_DIR = './test/fixtures/project'

  def build_path
    @build_path ||= Pathname.new(BUILD_DIR)
  end

  def section_export_path
    build_path.join('sections')
  end

  def project_path
    @project_path ||= Pathname.new(PROJECT_DIR)
  end

  def config_file
    project_path.join('config.yml')
  end

  def section_import_path
    project_path.join('sections')
  end

  def reset_build
    project.instance_variable_set(:@configuration, nil) if defined?(project)
    build_path.rmtree if build_path.exist?
  end
end
