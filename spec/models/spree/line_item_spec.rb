# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::LineItem do
  it { is_expected.to respond_to(:kit_item?) }
  it { is_expected.to belong_to(:kit).optional }
  it { is_expected.to have_many(:kit_items) }

  describe "#kit?" do
    subject(:line_item) { build(:line_item, variant: kit_product.master) }

    let(:kit_product) { create(:product) }
    let(:kit_item) { create(:variant) }

    before do
      create(:price, variant: kit_item, kit_item: true, currency: "USD")
      create(:kit_requirement, product: kit_product, required_product: kit_item.product)
    end

    it { is_expected.to be_kit }

    context "when asking the required line item" do
      let(:line_item) { build(:line_item, variant: kit_item) }

      it { is_expected.to be_kit }
    end
  end

  describe "kit completeness validation" do
    subject(:line_item) { build(:line_item, order: order, variant: kit_product.master, kit_items: []) }

    let(:kit_product) { create(:product) }
    let(:kit_item) { create(:variant) }
    let(:order) { create(:order) }

    before do
      create(:price, variant: kit_item, kit_item: true, currency: "USD")
      create(:kit_requirement, product: kit_product, required_product: kit_item.product)
    end

    it { is_expected.not_to be_valid }

    it "has the right error message" do
      line_item.valid?
      expect(line_item.errors.full_messages).to include(
        "Kit Items do not fulfill product kit requirements"
      )
    end

    context "when the line item fulfills the kit requirements" do
      before do
        line_item.kit_items.build(variant: kit_item, order: order, quantity: 1)
      end

      it { is_expected.to be_valid }
    end
  end
end
