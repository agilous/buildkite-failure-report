require 'spec_helper'
require_relative '../lib/main'

RSpec.describe BuildkiteFailureReport do
  describe '#initialize' do
    it 'creates a new instance' do
      expect(BuildkiteFailureReport.new).to be_a(BuildkiteFailureReport)
    end
  end
end