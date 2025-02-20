# frozen_string_literal: true

require 'httparty'
require_relative 'job_filter_service'

module Services
  class BuildkiteJobService
    include HTTParty
    base_uri 'https://api.buildkite.com/v2'

    class BuildkiteError < StandardError; end
    class RateLimitError < BuildkiteError; end
    class AuthenticationError < BuildkiteError; end
    class RSpecJobNotFoundError < BuildkiteError; end
    class LogNotFoundError < BuildkiteError; end

    def initialize(access_token)
      @access_token = access_token
      self.class.headers(
        'Authorization' => "Bearer #{@access_token}",
        'Content-Type' => 'application/json'
      )
    end

    # Finds the RSpec job in a build
    #
    # @param organization [String] Buildkite organization slug
    # @param pipeline [String] Pipeline slug
    # @param build_number [String] Build number
    # @return [Hash] The RSpec job details
    # @raise [RSpecJobNotFoundError] if RSpec job is not found
    def find_rspec_job(organization:, pipeline:, build_number:)
      jobs = fetch_job_details(
        organization: organization,
        pipeline: pipeline,
        build_number: build_number
      )

      rspec_job = JobFilterService.find_rspec_job(jobs)
      return rspec_job if rspec_job

      available_jobs = JobFilterService.available_job_names(jobs)
      raise RSpecJobNotFoundError, "RSpec job not found. Available jobs: #{available_jobs.join(', ')}"
    end

    def fetch_job_details(organization:, pipeline:, build_number:, job_id: nil)
      if job_id
        fetch_single_job(
          organization: organization,
          pipeline: pipeline,
          build_number: build_number,
          job_id: job_id
        )
      else
        fetch_all_jobs(
          organization: organization,
          pipeline: pipeline,
          build_number: build_number
        )
      end
    rescue HTTParty::Error => e
      raise BuildkiteError, "API request failed: #{e.message}"
    end

    # Fetches the log content for a specific job
    #
    # @param organization [String] Buildkite organization slug
    # @param pipeline [String] Pipeline slug
    # @param build_number [String] Build number
    # @param job_id [String] Job ID
    # @return [String] The job's log content
    # @raise [LogNotFoundError] if the log cannot be found
    # @raise [BuildkiteError] if there's an API error
    def fetch_job_log(organization:, pipeline:, build_number:, job_id:)
      response = self.class.get(
        "/organizations/#{organization}/pipelines/#{pipeline}/builds/#{build_number}/jobs/#{job_id}/log"
      )

      case response.code
      when 200
        parse_log_response(response)
      when 404
        raise LogNotFoundError, "Log not found for job #{job_id}"
      else
        handle_error_response(response)
      end
    rescue HTTParty::Error => e
      raise BuildkiteError, "API request failed: #{e.message}"
    end

    private

    def fetch_single_job(organization:, pipeline:, build_number:, job_id:)
      response = self.class.get(
        "/organizations/#{organization}/pipelines/#{pipeline}/builds/#{build_number}/jobs/#{job_id}"
      )

      handle_response(response)
    end

    def fetch_all_jobs(organization:, pipeline:, build_number:)
      response = self.class.get(
        "/organizations/#{organization}/pipelines/#{pipeline}/builds/#{build_number}"
      )

      build_data = handle_response(response)
      build_data['jobs'] || []
    end

    def handle_response(response)
      case response.code
      when 200
        response.parsed_response
      when 401
        raise AuthenticationError, 'Invalid access token'
      when 429
        raise RateLimitError, 'Rate limit exceeded'
      else
        raise BuildkiteError, "Unexpected response (#{response.code}): #{response.body}"
      end
    end

    def handle_error_response(response)
      case response.code
      when 401
        raise AuthenticationError, 'Invalid access token'
      when 429
        raise RateLimitError, 'Rate limit exceeded'
      else
        raise BuildkiteError, "Unexpected response (#{response.code}): #{response.body}"
      end
    end

    def parse_log_response(response)
      log_data = response.parsed_response
      return log_data['content'] if log_data.is_a?(Hash) && log_data['content']

      # Fallback for non-JSON responses or responses without content
      response.body
    end
  end
end