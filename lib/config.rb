require 'yaml'

module Conf
  extend self

  def config
    @config ||= YAML.load(File.read(config_path))
  end

  private

  def config_path
    File.join(File.dirname(__FILE__), "..", "config", "build-monitor.yml")
  end
end
