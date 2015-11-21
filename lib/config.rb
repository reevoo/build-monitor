require 'yaml'

module Config
  extend self

  def config
    @config ||= YAML.load(File.read(config_file_name))
  end

  private

  def config_path
    File.join(File.dirname(__FILE__), "..", "config", "build-monitor.yml")
  end
end
