# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Asset do
  describe 'associations' do
    it { is_expected.to belong_to(:recipe) }
  end

  describe 'validations' do
    # it { is_expected.to validate_presence_of(:profile) }
  end
end
