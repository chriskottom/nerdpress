require 'fileutils'

module BuildHelpers
  def build_path
    @build_path ||= Pathname.new('./test/tmp')
  end

  def reset_build
    project.instance_variable_set(:@config, nil) if defined?(project)
    build_path.rmtree if build_path.exist?
  end
end
