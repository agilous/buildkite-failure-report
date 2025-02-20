# frozen_string_literal: true

require 'spec_helper'
require 'services/json_formatter_service'
require 'services/log_parser_service'

RSpec.describe Services::JsonFormatterService do
  describe '.format_failures' do
    let(:test_failure) do
      Services::LogParserService::TestFailure.new(
        file_path: './spec/example_spec.rb',
        line_number: 42,
        description: 'test description',
        failure_message: 'expected true but got false',
        backtrace: ['./spec/example_spec.rb:42']
      )
    end

    context 'when there are test failures' do
      let(:failures) { [test_failure] }
      let(:expected_json) do
        JSON.pretty_generate([
          {
            file: './spec/example_spec.rb',
            line: 42,
            error_message: 'expected true but got false'
          }
        ])
      end

      it 'formats failures into the expected JSON structure' do
        expect(described_class.format_failures(failures)).to eq(expected_json)
      end

      it 'generates valid JSON' do
        result = described_class.format_failures(failures)
        expect { JSON.parse(result) }.not_to raise_error
      end
    end

    context 'when there are multiple test failures' do
      let(:another_failure) do
        Services::LogParserService::TestFailure.new(
          file_path: './spec/other_spec.rb',
          line_number: 15,
          description: 'another test',
          failure_message: 'expected nil but got Object',
          backtrace: ['./spec/other_spec.rb:15']
        )
      end
      let(:failures) { [test_failure, another_failure] }

      it 'formats all failures into JSON array' do
        result = JSON.parse(described_class.format_failures(failures))
        expect(result.size).to eq(2)
        expect(result.first['file']).to eq('./spec/example_spec.rb')
        expect(result.last['file']).to eq('./spec/other_spec.rb')
      end
    end

    context 'when there are no failures' do
      it 'returns empty JSON array for nil input' do
        expect(described_class.format_failures(nil)).to eq('[]')
      end

      it 'returns empty JSON array for empty input' do
        expect(described_class.format_failures([])).to eq('[]')
      end
    end

    context 'when there is an error during JSON generation' do
      let(:invalid_failure) { double('TestFailure') }
      let(:failures) { [invalid_failure] }

      before do
        allow(invalid_failure).to receive(:file_path).and_raise(NoMethodError)
      end

      it 'raises an error with descriptive message' do
        expect { described_class.format_failures(failures) }
          .to raise_error(/Failed to format test failures as JSON/)
      end
    end
  end
end