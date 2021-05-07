# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::LineItem do
  it { is_expected.to respond_to(:kit_item?) }
  it { is_expected.to belong_to(:kit).optional }
  it { is_expected.to have_many(:kit_items) }

  describe "#kit?" do
    let(:kit_product) { create(:product) }
    let(:price) { create(:price, kit_item: true) }
    let(:kit_item) { create(:variant, prices: [price]) }
    let!(:kit_requirement) { create(:kit_requirement, product: kit_product, required_product: kit_item.product) }
    let(:line_item) { build(:line_item, variant: kit_product.master) }
    
    subject { line_item.kit? }

    it { is_expected.to be true }

    context "when asking the required line item" do 
      let(:line_item) { build(:line_item, variant: kit_item) }

      it { is_expected.to be false }
    end
  end
end
