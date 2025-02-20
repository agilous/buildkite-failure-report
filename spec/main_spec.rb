# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/main'

RSpec.describe BuildkiteFailureReport::Main do
  subject(:reporter) { described_class.new }

  let(:organization) { 'my-org' }
  let(:pipeline) { 'my-pipeline' }
  let(:build_number) { '123' }
  let(:job_id) { '456' }
  let(:access_token) { 'test_token' }

  let(:rspec_job) do
    {
      'id' => job_id,
      'name' => ':rspec: RSpec',
      'state' => 'failed'
    }
  end

  let(:log_content) do
    <<~LOG
      Failures:

      1) Test example fails
         Failure/Error: expect(true).to be false

         expected false
         got: true
         # ./spec/example_spec.rb:42
    LOG
  end

  let(:expected_json) do
    JSON.pretty_generate([
      {
        file: './spec/example_spec.rb',
        line: 42,
        error_message: "Failure/Error: expect(true).to be false\nexpected false\ngot: true"
      }
    ])
  end

  before do
    allow(BuildkiteFailureReport::BuildkiteConfig).to receive(:api_token).and_return(access_token)
  end

  describe '#report_failures' do
    let(:job_service) { instance_double(Services::BuildkiteJobService) }

    before do
      allow(Services::BuildkiteJobService).to receive(:new)
        .with(access_token)
        .and_return(job_service)

      allow(job_service).to receive(:find_rspec_job)
        .with(organization: organization, pipeline: pipeline, build_number: build_number)
        .and_return(rspec_job)

      allow(job_service).to receive(:fetch_job_log)
        .with(organization: organization, pipeline: pipeline, build_number: build_number, job_id: job_id)
        .and_return(log_content)
    end

    it 'returns formatted JSON with test failures' do
      result = reporter.report_failures(
        organization: organization,
        pipeline: pipeline,
        build_number: build_number
      )

      expect(result).to eq(expected_json)
    end

    context 'when RSpec job is not found' do
      before do
        allow(job_service).to receive(:find_rspec_job)
          .and_raise(Services::BuildkiteJobService::RSpecJobNotFoundError, 'No RSpec job found')
      end

      it 'returns empty JSON array and logs warning' do
        expect do
          result = reporter.report_failures(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number
          )
          expect(result).to eq('[]')
        end.to output(/No RSpec job found/).to_stderr
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(job_service).to receive(:find_rspec_job)
          .and_raise(StandardError, 'Unexpected error')
      end

      it 'raises an error with descriptive message' do
        expect do
          reporter.report_failures(
            organization: organization,
            pipeline: pipeline,
            build_number: build_number
          )
        end.to raise_error(/Failed to generate test failure report: Unexpected error/)
      end
    end
  end
end