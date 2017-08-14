require "json"
require "ostruct"
require "yaml"

module NerdPress::Configuration
  def self.load(filename = nil)
    return OpenStruct.new unless filename

    if !File.exist?(filename)
      raise ArgumentError, "Configuration not found: #{ filename }"
    end

    yaml = YAML.load_file(filename) || {}
    JSON.parse(yaml.to_json, object_class: OpenStruct)
  end
end
