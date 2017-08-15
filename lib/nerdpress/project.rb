require 'pathname'

require_relative './configuration.rb'

class NerdPress::Project
  attr_reader :home_directory, :configuration
  alias_method :config, :configuration

  def initialize(home_dir = Dir.getwd)
    @home_directory = Pathname.new(home_dir).expand_path
    raise ArgumentError, 'Path does not exist' unless @home_directory.exist?
  end

  def configure(config_file = nil)
    config_file ||= home_directory.join('config.yml')
    @configuration = NerdPress::Configuration.load(config_file)
    yield @configuration if block_given?
    @configuration
  end

  def setup_logger!
    NerdPress::Logger.setup(log_dir: build_path, log_level: log_level)
  end

  private

  def build_path
    @build_dir ||= (config && config.build_dir) || home_directory.join('build')
    Pathname.new(@build_dir)
  end

  def log_level
    (config && config.log_level) || NerdPress::Logger::DEFAULT_LEVEL
  end
end
