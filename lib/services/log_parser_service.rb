# frozen_string_literal: true

module Services
  # Service class for parsing buildkite job logs and extracting RSpec test failures
  class LogParserService
    # Represents a parsed RSpec test failure
    class TestFailure
      attr_reader :file_path, :line_number, :description, :failure_message, :backtrace

      def initialize(file_path:, line_number:, description:, failure_message:, backtrace:)
        @file_path = file_path
        @line_number = line_number
        @description = description
        @failure_message = failure_message
        @backtrace = backtrace
      end

      def to_h
        {
          file_path: file_path,
          line_number: line_number,
          description: description,
          failure_message: failure_message,
          backtrace: backtrace
        }
      end
    end

    RSPEC_FAILURE_START = /^Failures:/.freeze
    RSPEC_FAILURE_PATTERN = /^\s*\d+\)\s(.+)$/.freeze
    LOCATION_PATTERN = /^(?:#\s+)?(.+?):(\d+)(?::in .+)?$/.freeze
    ANSI_COLOR_PATTERN = /\e\[\d+(?:;\d+)*m/.freeze

    def initialize(log_content)
      @log_content = log_content
      @failures = []
    end

    def parse
      return [] if @log_content.nil? || @log_content.empty?

      clean_content = strip_ansi_colors(@log_content)
      extract_failures(clean_content)
      @failures
    rescue StandardError => e
      raise "Failed to parse log content: #{e.message}"
    end

    private

    def strip_ansi_colors(text)
      text.gsub(ANSI_COLOR_PATTERN, '')
    end

    def extract_failures(content)
      lines = content.split("\n")
      failure_section_start = lines.find_index { |line| line.match?(RSPEC_FAILURE_START) }
      return if failure_section_start.nil?

      current_failure = nil
      current_backtrace = []
      in_backtrace = false

      lines[failure_section_start..].each do |line|
        if line.match?(RSPEC_FAILURE_PATTERN)
          save_current_failure(current_failure, current_backtrace) if current_failure
          current_failure = parse_failure_header(line)
          current_backtrace = []
          in_backtrace = false
        elsif current_failure
          if line.match?(LOCATION_PATTERN) && !in_backtrace
            in_backtrace = true
            current_backtrace << line.strip
          elsif in_backtrace && !line.strip.empty?
            current_backtrace << line.strip
          elsif !in_backtrace && !line.strip.empty?
            current_failure[:failure_message] ||= ''
            current_failure[:failure_message] += "#{line.strip}\n"
          end
        end
      end

      save_current_failure(current_failure, current_backtrace) if current_failure
    end

    def parse_failure_header(line)
      match = line.match(RSPEC_FAILURE_PATTERN)
      return unless match

      {
        description: match[1].strip,
        failure_message: ''
      }
    end

    def save_current_failure(failure_data, backtrace)
      return unless failure_data && !backtrace.empty?

      location = parse_location(backtrace.first)
      return unless location

      @failures << TestFailure.new(
        file_path: location[:file],
        line_number: location[:line],
        description: failure_data[:description],
        failure_message: failure_data[:failure_message].strip,
        backtrace: backtrace
      )
    end

    def parse_location(location_line)
      match = location_line.match(LOCATION_PATTERN)
      return unless match

      {
        file: match[1],
        line: match[2].to_i
      }
    end
  end
end