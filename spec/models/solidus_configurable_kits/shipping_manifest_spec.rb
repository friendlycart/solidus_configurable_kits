# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusConfigurableKits::ShippingManifest do
  subject { described_class.new(inventory_units: order.inventory_units).items }

  let(:order) { create(:order) }

  it { is_expected.to eq([]) }
end
