# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/buildkite_config'

RSpec.describe BuildkiteFailureReport::BuildkiteConfig do
  let(:config_path) { described_class::CONFIG_PATH }

  describe '.api_token' do
    subject(:api_token) { described_class.api_token }

    context 'when config file exists with valid token' do
      before do
        allow(File).to receive(:exist?).with(config_path).and_return(true)
        allow(YAML).to receive(:safe_load_file).with(config_path).and_return(
          { 'token' => 'valid_token' }
        )
      end

      it 'returns the API token' do
        expect(api_token).to eq('valid_token')
      end
    end

    context 'when config file does not exist' do
      before do
        allow(File).to receive(:exist?).with(config_path).and_return(false)
      end

      it 'raises a ConfigError' do
        expect { api_token }.to raise_error(
          BuildkiteFailureReport::BuildkiteConfig::ConfigError,
          'Buildkite config file not found at ~/.buildkite/config.yml'
        )
      end
    end

    context 'when config file contains invalid YAML' do
      before do
        allow(File).to receive(:exist?).with(config_path).and_return(true)
        allow(YAML).to receive(:safe_load_file).with(config_path)
          .and_raise(Psych::SyntaxError.new('file', 1, 1, 0, 'syntax error', 'problem'))
      end

      it 'raises a ConfigError' do
        expect { api_token }.to raise_error(
          BuildkiteFailureReport::BuildkiteConfig::ConfigError,
          /Invalid YAML in config file/
        )
      end
    end

    context 'when config file is missing token' do
      before do
        allow(File).to receive(:exist?).with(config_path).and_return(true)
        allow(YAML).to receive(:safe_load_file).with(config_path).and_return({})
      end

      it 'raises a ConfigError' do
        expect { api_token }.to raise_error(
          BuildkiteFailureReport::BuildkiteConfig::ConfigError,
          'Config file is missing token'
        )
      end
    end
  end
end