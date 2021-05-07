# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusConfigurableKits::AddKit do
  subject(:add_kit) { described_class.new(order).call(variant, 1, kit_variant_quantities) }

  let(:order) { create(:order) }
  let(:variant) { create(:variant) }
  let(:kit_requirement) { create(:kit_requirement, product: variant.product) }
  let(:kit_variants) { [kit_requirement.required_product.master] }
  let(:kit_variant_quantities) { kit_variants.map { |v| [v, 1] } }

  it "adds kit variants to the order" do
    add_kit
    expect(order.variants).to match_array([variant] + kit_variants)
  end
end
