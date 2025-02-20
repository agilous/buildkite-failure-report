# frozen_string_literal: true

module Services
  # Service for filtering and managing Buildkite jobs
  class JobFilterService
    RSPEC_JOB_NAME = ':rspec: RSpec'

    # Filters the list of jobs to find the RSpec job
    #
    # @param jobs [Array<Hash>] List of Buildkite jobs
    # @return [Hash, nil] The RSpec job if found, nil otherwise
    def self.find_rspec_job(jobs)
      jobs.find { |job| job['name'] == RSPEC_JOB_NAME }
    end

    # Gets a list of available job names
    #
    # @param jobs [Array<Hash>] List of Buildkite jobs
    # @return [Array<String>] List of unique, non-nil job names, sorted alphabetically
    def self.available_job_names(jobs)
      jobs
        .map { |job| job['name'] }
        .compact
        .uniq
        .sort
    end
  end
end