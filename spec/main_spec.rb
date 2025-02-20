# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/main'

RSpec.describe BuildkiteFailureReport::Main do
  describe '#initialize' do
    it 'creates a new instance' do
      expect(described_class.new).to be_a(BuildkiteFailureReport::Main)
    end
  end
end