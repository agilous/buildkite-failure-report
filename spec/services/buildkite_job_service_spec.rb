# frozen_string_literal: true

require 'spec_helper'
require 'services/buildkite_job_service'
require 'webmock/rspec'

RSpec.describe Services::BuildkiteJobService do
  let(:access_token) { 'fake_token' }
  let(:organization) { 'my-org' }
  let(:pipeline) { 'my-pipeline' }
  let(:build_number) { '123' }
  let(:job_id) { '456' }
  let(:base_url) { 'https://api.buildkite.com/v2' }
  let(:single_job_endpoint) do
    "/organizations/#{organization}/pipelines/#{pipeline}/builds/#{build_number}/jobs/#{job_id}"
  end
  let(:build_endpoint) do
    "/organizations/#{organization}/pipelines/#{pipeline}/builds/#{build_number}"
  end
  let(:log_endpoint) do
    "/organizations/#{organization}/pipelines/#{pipeline}/builds/#{build_number}/jobs/#{job_id}/log"
  end

  subject(:service) { described_class.new(access_token) }

  describe '#fetch_job_details' do
    context 'when fetching a single job' do
      context 'when the request is successful' do
        let(:job_data) do
          {
            'id' => job_id,
            'state' => 'passed',
            'web_url' => 'https://buildkite.com/my-org/my-pipeline/builds/123#456'
          }
        end

        before do
          stub_request(:get, "#{base_url}#{single_job_endpoint}")
            .with(
              headers: {
                'Authorization' => "Bearer #{access_token}",
                'Content-Type' => 'application/json'
              }
            )
            .to_return(
              status: 200,
              body: job_data.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        it 'returns the job details' do
          result = service.fetch_job_details(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number,
            job_id: job_id
          )
          expect(result).to eq(job_data)
        end
      end

      context 'when authentication fails' do
        before do
          stub_request(:get, "#{base_url}#{single_job_endpoint}")
            .to_return(status: 401, body: '{"message": "Unauthorized"}')
        end

        it 'raises an AuthenticationError' do
          expect do
            service.fetch_job_details(
              organization: organization,
              pipeline: pipeline,
              build_number: build_number,
              job_id: job_id
            )
          end.to raise_error(Services::BuildkiteJobService::AuthenticationError, 'Invalid access token')
        end
      end
    end

    context 'when fetching all jobs for a build' do
      let(:build_data) do
        {
          'id' => build_number,
          'jobs' => [
            {
              'id' => '456',
              'state' => 'passed',
              'web_url' => 'https://buildkite.com/my-org/my-pipeline/builds/123#456'
            },
            {
              'id' => '457',
              'state' => 'failed',
              'web_url' => 'https://buildkite.com/my-org/my-pipeline/builds/123#457'
            }
          ]
        }
      end

      context 'when the request is successful' do
        before do
          stub_request(:get, "#{base_url}#{build_endpoint}")
            .with(
              headers: {
                'Authorization' => "Bearer #{access_token}",
                'Content-Type' => 'application/json'
              }
            )
            .to_return(
              status: 200,
              body: build_data.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        it 'returns all jobs for the build' do
          result = service.fetch_job_details(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number
          )
          expect(result).to eq(build_data['jobs'])
        end
      end

      context 'when the build has no jobs' do
        let(:build_data_without_jobs) { { 'id' => build_number } }

        before do
          stub_request(:get, "#{base_url}#{build_endpoint}")
            .to_return(
              status: 200,
              body: build_data_without_jobs.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        it 'returns an empty array' do
          result = service.fetch_job_details(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number
          )
          expect(result).to eq([])
        end
      end

      context 'when rate limit is exceeded' do
        before do
          stub_request(:get, "#{base_url}#{build_endpoint}")
            .to_return(status: 429, body: '{"message": "Too Many Requests"}')
        end

        it 'raises a RateLimitError' do
          expect do
            service.fetch_job_details(
              organization: organization,
              pipeline: pipeline,
              build_number: build_number
            )
          end.to raise_error(Services::BuildkiteJobService::RateLimitError, 'Rate limit exceeded')
        end
      end
    end

    context 'when an unexpected error occurs' do
      before do
        stub_request(:get, "#{base_url}#{single_job_endpoint}")
          .to_return(status: 500, body: '{"message": "Internal Server Error"}')
      end

      it 'raises a BuildkiteError' do
        expect do
          service.fetch_job_details(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number,
            job_id: job_id
          )
        end.to raise_error(Services::BuildkiteJobService::BuildkiteError, /Unexpected response/)
      end
    end

    context 'when the HTTP request fails' do
      before do
        stub_request(:get, "#{base_url}#{single_job_endpoint}")
          .to_raise(HTTParty::Error.new('Network error'))
      end

      it 'raises a BuildkiteError' do
        expect do
          service.fetch_job_details(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number,
            job_id: job_id
          )
        end.to raise_error(Services::BuildkiteJobService::BuildkiteError, /API request failed/)
      end
    end
  end

  describe '#find_rspec_job' do
    let(:rspec_job) do
      {
        'id' => '456',
        'name' => ':rspec: RSpec',
        'state' => 'passed'
      }
    end

    let(:other_job) do
      {
        'id' => '457',
        'name' => ':ruby: Lint',
        'state' => 'passed'
      }
    end

    let(:build_data) do
      {
        'id' => build_number,
        'jobs' => [rspec_job, other_job]
      }
    end

    before do
      stub_request(:get, "#{base_url}#{build_endpoint}")
        .with(
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: build_data.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    context 'when RSpec job exists' do
      it 'returns the RSpec job' do
        result = service.find_rspec_job(
          organization: organization,
          pipeline: pipeline,
          build_number: build_number
        )
        expect(result).to eq(rspec_job)
      end
    end

    context 'when RSpec job does not exist' do
      let(:build_data) do
        {
          'id' => build_number,
          'jobs' => [other_job]
        }
      end

      it 'raises RSpecJobNotFoundError with available jobs' do
        expect do
          service.find_rspec_job(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number
          )
        end.to raise_error(
          Services::BuildkiteJobService::RSpecJobNotFoundError,
          'RSpec job not found. Available jobs: :ruby: Lint'
        )
      end
    end
  end

  describe '#fetch_job_log' do
    context 'when the request is successful' do
      let(:raw_log_content) { "Running RSpec...\nTest failed: expected true but got false" }
      let(:log_response) do
        {
          'url' => "#{base_url}#{log_endpoint}",
          'content' => raw_log_content,
          'size' => raw_log_content.bytesize,
          'header_times' => {
            'started' => '2024-02-20T12:00:00.000Z',
            'finished' => '2024-02-20T12:01:00.000Z'
          }
        }
      end

      before do
        stub_request(:get, "#{base_url}#{log_endpoint}")
          .with(
            headers: {
              'Authorization' => "Bearer #{access_token}",
              'Content-Type' => 'application/json'
            }
          )
          .to_return(
            status: 200,
            body: log_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns the log content' do
        result = service.fetch_job_log(
          organization: organization,
          pipeline: pipeline,
          build_number: build_number,
          job_id: job_id
        )
        expect(result).to eq(raw_log_content)
      end
    end

    context 'when the response is not in JSON format' do
      let(:raw_log_content) { "Plain text log content" }

      before do
        stub_request(:get, "#{base_url}#{log_endpoint}")
          .with(
            headers: {
              'Authorization' => "Bearer #{access_token}",
              'Content-Type' => 'application/json'
            }
          )
          .to_return(
            status: 200,
            body: raw_log_content,
            headers: { 'Content-Type' => 'text/plain' }
          )
      end

      it 'returns the raw log content' do
        result = service.fetch_job_log(
          organization: organization,
          pipeline: pipeline,
          build_number: build_number,
          job_id: job_id
        )
        expect(result).to eq(raw_log_content)
      end
    end

    context 'when the log is not found' do
      before do
        stub_request(:get, "#{base_url}#{log_endpoint}")
          .to_return(status: 404, body: '{"message": "Log not found"}')
      end

      it 'raises a LogNotFoundError' do
        expect do
          service.fetch_job_log(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number,
            job_id: job_id
          )
        end.to raise_error(Services::BuildkiteJobService::LogNotFoundError, /Log not found for job/)
      end
    end

    context 'when authentication fails' do
      before do
        stub_request(:get, "#{base_url}#{log_endpoint}")
          .to_return(status: 401, body: '{"message": "Unauthorized"}')
      end

      it 'raises an AuthenticationError' do
        expect do
          service.fetch_job_log(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number,
            job_id: job_id
          )
        end.to raise_error(Services::BuildkiteJobService::AuthenticationError, 'Invalid access token')
      end
    end

    context 'when rate limit is exceeded' do
      before do
        stub_request(:get, "#{base_url}#{log_endpoint}")
          .to_return(status: 429, body: '{"message": "Too Many Requests"}')
      end

      it 'raises a RateLimitError' do
        expect do
          service.fetch_job_log(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number,
            job_id: job_id
          )
        end.to raise_error(Services::BuildkiteJobService::RateLimitError, 'Rate limit exceeded')
      end
    end

    context 'when an unexpected error occurs' do
      before do
        stub_request(:get, "#{base_url}#{log_endpoint}")
          .to_return(status: 500, body: '{"message": "Internal Server Error"}')
      end

      it 'raises a BuildkiteError' do
        expect do
          service.fetch_job_log(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number,
            job_id: job_id
          )
        end.to raise_error(Services::BuildkiteJobService::BuildkiteError, /Unexpected response/)
      end
    end

    context 'when the HTTP request fails' do
      before do
        stub_request(:get, "#{base_url}#{log_endpoint}")
          .to_raise(HTTParty::Error.new('Network error'))
      end

      it 'raises a BuildkiteError' do
        expect do
          service.fetch_job_log(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number,
            job_id: job_id
          )
        end.to raise_error(Services::BuildkiteJobService::BuildkiteError, /API request failed/)
      end
    end
  end
end