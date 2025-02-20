# frozen_string_literal: true

require 'yaml'

module BuildkiteFailureReport
  # Handles reading and parsing of Buildkite configuration
  class BuildkiteConfig
    CONFIG_PATH = File.expand_path('~/.buildkite/config.yml')

    class ConfigError < StandardError; end

    # Reads the Buildkite API token from the config file
    #
    # @return [String] the API token
    # @raise [ConfigError] if the config file is missing or malformed
    def self.api_token
      new.api_token
    end

    # @return [String] the API token from config
    # @raise [ConfigError] if the config file is missing or malformed
    def api_token
      validate_config_file!
      config = load_config
      validate_token!(config)
      config['token']
    end

    private

    def validate_config_file!
      return if File.exist?(CONFIG_PATH)

      raise ConfigError, 'Buildkite config file not found at ~/.buildkite/config.yml'
    end

    def load_config
      YAML.safe_load_file(CONFIG_PATH)
    rescue Psych::SyntaxError => e
      raise ConfigError, "Invalid YAML in config file: #{e.message}"
    end

    def validate_token!(config)
      return if config.is_a?(Hash) && config['token'].is_a?(String)

      raise ConfigError, 'Config file is missing token'
    end
  end
end