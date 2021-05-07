# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusConfigurableKits::Requirement do
  it { is_expected.to belong_to :product }
  it { is_expected.to belong_to :required_product }
  it { is_expected.to respond_to :quantity }
  it { is_expected.to respond_to :description }

  describe "validations" do
    subject(:requirement) { build(:kit_requirement, required_product: required_product) }

    let(:required_product) { create(:product) }
    let(:price) { create(:price, kit_item: true) }

    before do
      required_product.master.prices << price
    end

    it { is_expected.to be_valid }

    context "when there is no price for kit items on the required product" do
      let(:price) { create(:price, kit_item: false) }

      it { is_expected.not_to be_valid }

      it "has the right error message" do
        requirement.valid?
        expect(requirement.errors.full_messages).to include(
          "Required Product needs to have at least one variant with a kit price"
        )
      end
    end
  end
end
