# frozen_string_literal: true

require 'spec_helper'
require 'services/job_filter_service'

RSpec.describe Services::JobFilterService do
  let(:rspec_job) do
    {
      'id' => '123',
      'name' => ':rspec: RSpec',
      'state' => 'passed'
    }
  end

  let(:other_job) do
    {
      'id' => '456',
      'name' => ':ruby: Lint',
      'state' => 'passed'
    }
  end

  let(:jobs) { [rspec_job, other_job] }

  describe '.find_rspec_job' do
    subject(:find_rspec_job) { described_class.find_rspec_job(jobs) }

    context 'when RSpec job exists' do
      it 'returns the RSpec job' do
        expect(find_rspec_job).to eq(rspec_job)
      end
    end

    context 'when RSpec job does not exist' do
      let(:jobs) { [other_job] }

      it 'returns nil' do
        expect(find_rspec_job).to be_nil
      end
    end

    context 'when jobs list is empty' do
      let(:jobs) { [] }

      it 'returns nil' do
        expect(find_rspec_job).to be_nil
      end
    end
  end

  describe '.available_job_names' do
    subject(:available_job_names) { described_class.available_job_names(jobs) }

    it 'returns a sorted list of job names' do
      expect(available_job_names).to eq([":rspec: RSpec", ":ruby: Lint"])
    end

    context 'when jobs list is empty' do
      let(:jobs) { [] }

      it 'returns an empty array' do
        expect(available_job_names).to be_empty
      end
    end

    context 'when there are duplicate job names' do
      let(:duplicate_rspec_job) do
        {
          'id' => '789',
          'name' => ':rspec: RSpec',
          'state' => 'failed'
        }
      end
      let(:jobs) { [rspec_job, other_job, duplicate_rspec_job] }

      it 'returns only unique job names' do
        expect(available_job_names).to eq([":rspec: RSpec", ":ruby: Lint"])
      end
    end

    context 'when some jobs have nil names' do
      let(:nil_name_job) { { 'id' => '999', 'name' => nil, 'state' => 'passed' } }
      let(:jobs) { [rspec_job, other_job, nil_name_job] }

      it 'excludes nil names from the result' do
        expect(available_job_names).to eq([":rspec: RSpec", ":ruby: Lint"])
      end
    end
  end
end