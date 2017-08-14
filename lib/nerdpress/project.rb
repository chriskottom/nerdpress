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
end
