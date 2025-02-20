# frozen_string_literal: true

require 'httparty'

module Services
  class BuildkiteJobService
    include HTTParty
    base_uri 'https://api.buildkite.com/v2'

    class BuildkiteError < StandardError; end
    class RateLimitError < BuildkiteError; end
    class AuthenticationError < BuildkiteError; end

    def initialize(access_token)
      @access_token = access_token
      self.class.headers(
        'Authorization' => "Bearer #{@access_token}",
        'Content-Type' => 'application/json'
      )
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
  end
end