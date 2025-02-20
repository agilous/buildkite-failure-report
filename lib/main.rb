# frozen_string_literal: true

require_relative 'buildkite_config'
require_relative 'services/buildkite_job_service'
require_relative 'services/log_parser_service'
require_relative 'services/json_formatter_service'

module BuildkiteFailureReport
  # Main class that orchestrates the test failure reporting process
  class Main
    def initialize
      @job_service = Services::BuildkiteJobService.new(BuildkiteConfig.api_token)
    end

    def report_failures(organization:, pipeline:, build_number:)
      rspec_job = @job_service.find_rspec_job(
        organization: organization,
        pipeline: pipeline,
        build_number: build_number
      )

      log_content = @job_service.fetch_job_log(
        organization: organization,
        pipeline: pipeline,
        build_number: build_number,
        job_id: rspec_job['id']
      )

      failures = Services::LogParserService.new(log_content).parse
      Services::JsonFormatterService.format_failures(failures)
    rescue Services::BuildkiteJobService::RSpecJobNotFoundError => e
      # Return empty array when RSpec job is not found, but log available jobs
      warn e.message
      '[]'
    rescue StandardError => e
      raise "Failed to generate test failure report: #{e.message}"
    end
  end
end