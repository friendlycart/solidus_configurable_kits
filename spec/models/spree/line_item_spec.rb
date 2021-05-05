# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::LineItem do
  it { is_expected.to respond_to(:kit_item?) }
  it { is_expected.to belong_to(:kit).optional }
  it { is_expected.to have_many(:kit_items) }
end
