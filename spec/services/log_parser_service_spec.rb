# frozen_string_literal: true

require 'spec_helper'
require 'services/log_parser_service'

RSpec.describe Services::LogParserService do
  subject(:parser) { described_class.new(log_content) }

  describe '#parse' do
    context 'with invalid input' do
      context 'when log content is nil' do
        let(:log_content) { nil }

        it 'returns an empty array' do
          expect(parser.parse).to eq([])
        end
      end

      context 'when log content is empty' do
        let(:log_content) { '' }

        it 'returns an empty array' do
          expect(parser.parse).to eq([])
        end
      end
    end

    context 'with valid RSpec failure logs' do
      let(:log_content) do
        <<~LOG
          Failures:

          1) UserService#process handles invalid input
             \e[31mFailure/Error:\e[0m \e[31mexpect(service.process).to be_valid\e[0m

             \e[31mexpected #<User id: nil> to be valid, but got errors:\e[0m
             \e[31m  * Name can't be blank\e[0m
             \e[31m  * Email is invalid\e[0m
             # ./spec/services/user_service_spec.rb:25:in `block (3 levels) in <top (required)>'

          2) PostService creates a new post
             \e[31mFailure/Error:\e[0m \e[31mraise "Database connection error"\e[0m

             \e[31mRuntimeError:\e[0m
             \e[31m  Database connection error\e[0m
             # ./app/services/post_service.rb:45:in `create'
             # ./spec/services/post_service_spec.rb:15:in `block (2 levels) in <top (required)>'
        LOG
      end

      it 'extracts all test failures' do
        failures = parser.parse
        expect(failures.size).to eq(2)
      end

      it 'correctly parses the first failure' do
        failure = parser.parse.first

        expect(failure.file_path).to eq('./spec/services/user_service_spec.rb')
        expect(failure.line_number).to eq(25)
        expect(failure.description).to eq('UserService#process handles invalid input')
        expect(failure.failure_message).to include("expected #<User id: nil> to be valid, but got errors:")
        expect(failure.failure_message).to include("* Name can't be blank")
        expect(failure.failure_message).to include("* Email is invalid")
      end

      it 'correctly parses the second failure' do
        failure = parser.parse.last

        expect(failure.file_path).to eq('./app/services/post_service.rb')
        expect(failure.line_number).to eq(45)
        expect(failure.description).to eq('PostService creates a new post')
        expect(failure.failure_message).to include('RuntimeError:')
        expect(failure.failure_message).to include('Database connection error')
      end

      it 'preserves the backtrace' do
        failure = parser.parse.last
        expect(failure.backtrace).to match_array([
          "# ./app/services/post_service.rb:45:in `create'",
          "# ./spec/services/post_service_spec.rb:15:in `block (2 levels) in <top (required)>'"
        ])
      end
    end

    context 'with ANSI color codes' do
      let(:log_content) do
        <<~LOG
          Failures:

          1) Test with colors
             \e[31mFailure/Error:\e[0m \e[31mexpect(true).to be false\e[0m

             \e[31mexpected false\e[0m
             \e[31mgot: true\e[0m
             # ./spec/example_spec.rb:10
        LOG
      end

      it 'strips ANSI color codes from the output' do
        failure = parser.parse.first
        expect(failure.failure_message).not_to include('\e[31m')
        expect(failure.failure_message).not_to include('\e[0m')
        expect(failure.failure_message).to include('expected false')
        expect(failure.failure_message).to include('got: true')
      end
    end

    context 'with multi-line error messages' do
      let(:log_content) do
        <<~LOG
          Failures:

          1) Complex error
             Failure/Error: expect(complex).to be_valid

             JSON::ParserError:
               unexpected token at '{"invalid": json'
               with additional context
               spanning multiple lines
             # ./spec/complex_spec.rb:20
        LOG
      end

      it 'preserves multi-line error messages' do
        failure = parser.parse.first
        expect(failure.failure_message).to include("JSON::ParserError:")
        expect(failure.failure_message).to include("unexpected token at '{\"invalid\": json'")
        expect(failure.failure_message).to include("with additional context")
        expect(failure.failure_message).to include("spanning multiple lines")
      end
    end

    context 'with malformed failure blocks' do
      let(:log_content) do
        <<~LOG
          Failures:

          1) Malformed failure without location
             Failure/Error: something went wrong

          2) Valid failure
             Failure/Error: expect(true).to be false
             # ./spec/valid_spec.rb:15
        LOG
      end

      it 'skips malformed failures and continues parsing' do
        failures = parser.parse
        expect(failures.size).to eq(1)
        expect(failures.first.file_path).to eq('./spec/valid_spec.rb')
      end
    end
  end

  describe '#to_h conversion' do
    let(:log_content) do
      <<~LOG
        Failures:

        1) Simple test
           Failure/Error: expect(1).to eq(2)

           expected: 2
           got: 1
           # ./spec/simple_spec.rb:5
      LOG
    end

    it 'converts TestFailure to hash with all attributes' do
      failure = parser.parse.first
      hash = failure.to_h

      expect(hash).to include(
        file_path: './spec/simple_spec.rb',
        line_number: 5,
        description: 'Simple test',
        failure_message: "Failure/Error: expect(1).to eq(2)\nexpected: 2\ngot: 1",
        backtrace: ['# ./spec/simple_spec.rb:5']
      )
    end
  end
end