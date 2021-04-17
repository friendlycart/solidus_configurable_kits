# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusConfigurableKits::Requirement do
  it { is_expected.to belong_to :product }
  it { is_expected.to belong_to :required_product }
  it { is_expected.to respond_to :quantity }
  it { is_expected.to respond_to :description }
end
