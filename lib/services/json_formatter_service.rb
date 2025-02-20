# frozen_string_literal: true

require 'json'

module Services
  # Service class for formatting test failures into JSON
  class JsonFormatterService
    def self.format_failures(failures)
      return '[]' if failures.nil? || failures.empty?

      failures_array = failures.map do |failure|
        {
          file: failure.file_path,
          line: failure.line_number,
          error_message: failure.failure_message
        }
      end

      JSON.pretty_generate(failures_array)
    rescue StandardError => e
      raise "Failed to format test failures as JSON: #{e.message}"
    end
  end
end