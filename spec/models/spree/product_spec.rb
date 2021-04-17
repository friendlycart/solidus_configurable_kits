# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::Product do
  it { is_expected.to have_many(:kit_requirements) }
  it { is_expected.to have_many(:kits) }
  it { is_expected.to have_many(:required_kit_products) }
end
