# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusConfigurableKits::OrderMerger, type: :model do
  let(:variant) { create(:variant) }
  let!(:store) { create(:store, default: true) }
  let(:order_1) { Spree::Order.create }
  let(:order_2) { Spree::Order.create }
  let(:user) { create(:user, email: "solidus@example.com") }
  let(:subject) { described_class.new(order_1) }

  it "destroys the other order" do
    subject.merge!(order_2)
    expect { order_2.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "persist the merge" do
    expect(subject).to receive(:persist_merge)
    subject.merge!(order_2)
  end

  context "user is provided" do
    it "assigns user to new order" do
      subject.merge!(order_2, user)
      expect(order_1.user).to eq user
    end
  end

  context "merging together two orders with line items for the same variant" do
    before do
      order_1.contents.add(variant, 1)
      order_2.contents.add(variant, 1)
    end

    specify do
      subject.merge!(order_2, user)
      expect(order_1.line_items.count).to eq(1)

      line_item = order_1.line_items.first
      expect(line_item.quantity).to eq(2)
      expect(line_item.variant_id).to eq(variant.id)
    end
  end

  context 'merging together two orders with multiple currencies line items' do
    let(:order_2) { Spree::Order.create(currency: 'JPY') }
    let(:variant_2) { create(:variant) }

    before do
      Spree::Price.create(variant: variant_2, amount: 10, currency: 'JPY')
      order_1.contents.add(variant, 1)
      order_2.contents.add(variant_2.reload, 1)
    end

    it 'rejects other order line items' do
      subject.merge!(order_2, user)
      expect(order_1.line_items.count).to eq(1)

      line_item = order_1.line_items.first
      expect(line_item.quantity).to eq(1)
      expect(line_item.variant_id).to eq(variant.id)
    end
  end

  context "merging orders with configurable kits" do
    let(:kit_product) { create(:product) }
    let!(:kit_item_product) { create(:product, variants: [kit_item_1, kit_item_2]) }
    let(:kit_item_1) { build(:variant, prices: [kit_item_1_price]) }
    let(:kit_item_2) { build(:variant, prices: [kit_item_2_price]) }
    let(:kit_item_1_price) { create(:price, kit_item: true, currency: "USD") }
    let(:kit_item_2_price) { create(:price, kit_item: true, currency: "USD") }
    let!(:kit_requirement) { create(:kit_requirement, product: kit_product, required_product: kit_item_product) }

    context "the old order is empty, the new order has a kit" do
      before do
        order_1.contents.add(kit_product.master, 1, kit_variant_ids: { kit_requirement.id.to_s => kit_item_1.id.to_s })
      end

      it "does not lose the kit" do
        subject.merge!(order_2, user)
        expect(order_2).to be_destroyed
        expect(order_1.line_items.count).to eq(2)
        expect(order_1.line_items.all?(&:valid?)).to be true
      end
    end

    context "the old order has a kit, the new order is empty" do
      before do
        order_2.contents.add(kit_product.master, 1, kit_variant_ids: { kit_requirement.id.to_s => kit_item_1.id.to_s })
      end

      it "does not lose the kit" do
        expect(order_1.line_items.length).to eq(0)
        subject.merge!(order_2, user)
        expect(order_2).to be_destroyed
        expect(order_1.line_items.length).to eq(2)
        expect(order_1.line_items.all?(&:valid?)).to be true
      end
    end

    context "both orders have a kit with different kit items" do
      before do
        order_1.contents.add(kit_product.master, 1, kit_variant_ids: { kit_requirement.id.to_s => kit_item_1.id.to_s })
        order_2.contents.add(kit_product.master, 1, kit_variant_ids: { kit_requirement.id.to_s => kit_item_2.id.to_s })
      end

      it "keeps both kits" do
        expect(order_1.reload.line_items.length).to eq(2)
        expect(order_2.reload.line_items.length).to eq(2)
        subject.merge!(order_2, user)
        expect(order_2).to be_destroyed
        expect(order_1.reload.line_items.count(&:kit?)).to eq(2)
        expect(order_1.line_items.count(&:kit_item?)).to eq(2)
        expect(order_1.line_items.length).to eq(4)
        expect(order_1.line_items.all?(&:valid?)).to be true
      end
    end

    context "both orders have identical kits" do
      before do
        order_1.contents.add(kit_product.master, 1, kit_variant_ids: { kit_requirement.id.to_s => kit_item_1.id.to_s })
        order_2.contents.add(kit_product.master, 1, kit_variant_ids: { kit_requirement.id.to_s => kit_item_1.id.to_s })
      end

      it "keeps both kits" do
        expect(order_1.reload.line_items.length).to eq(2)
        expect(order_2.reload.line_items.length).to eq(2)
        subject.merge!(order_2, user)
        expect(order_2).to be_destroyed
        expect(order_1.reload.line_items.detect(&:kit?).quantity).to eq(2)
        expect(order_1.line_items.detect(&:kit_item?).quantity).to eq(2)
        expect(order_1.reload.line_items.count(&:kit?)).to eq(1)
        expect(order_1.line_items.count(&:kit_item?)).to eq(1)
        expect(order_1.line_items.length).to eq(2)
        expect(order_1.line_items.all?(&:valid?)).to be true
      end
    end
  end

  context "merging using extension-specific line_item_comparison_hooks" do
    around do |example|
      previous_hooks = Spree::Order.line_item_comparison_hooks.dup

      Spree::Order.register_line_item_comparison_hook(:foos_match)
      example.run
      Spree::Order.line_item_comparison_hooks = previous_hooks
    end

    context "2 equal line items" do
      before do
        @line_item_one = order_1.contents.add(variant, 1, foos: {})
        @line_item_two = order_2.contents.add(variant, 1, foos: {})
      end

      specify do
        without_partial_double_verification do
          expect(order_1).to receive(:foos_match).with(@line_item_one, kind_of(Hash)).and_return(true)
        end
        subject.merge!(order_2)
        expect(order_1.line_items.count).to eq(1)

        line_item = order_1.line_items.first
        expect(line_item.quantity).to eq(2)
        expect(line_item.variant_id).to eq(variant.id)
      end
    end

    context "2 different line items" do
      before do
        without_partial_double_verification do
          allow(order_1).to receive(:foos_match).and_return(false)
        end

        order_1.contents.add(variant, 1, foos: {})
        order_2.contents.add(variant, 1, foos: { bar: :zoo })
      end

      specify do
        subject.merge!(order_2)
        expect(order_1.line_items.count).to eq(2)

        line_item = order_1.line_items.first
        expect(line_item.quantity).to eq(1)
        expect(line_item.variant_id).to eq(variant.id)

        line_item = order_1.line_items.last
        expect(line_item.quantity).to eq(1)
        expect(line_item.variant_id).to eq(variant.id)
      end
    end
  end

  context "merging together two orders with different line items" do
    let(:variant_2) { create(:variant) }

    before do
      order_1.contents.add(variant, 1)
      order_2.contents.add(variant_2, 1)
    end

    specify do
      subject.merge!(order_2)

      # Both in memory and in DB line items
      expect(order_1.line_items.length).to eq(2)
      expect(order_1.line_items.count).to eq(2)

      expect(order_1.item_count).to eq 2
      expect(order_1.item_total).to eq order_1.line_items.sum(&:amount)

      # No guarantee on ordering of line items, so we do this:
      expect(order_1.line_items.pluck(:quantity)).to match_array([1, 1])
      expect(order_1.line_items.pluck(:variant_id)).to match_array([variant.id, variant_2.id])
    end

    context "with line item promotion applied to order 2" do
      let!(:promotion) { create(:promotion, :with_line_item_adjustment, apply_automatically: true) }

      before do
        Spree::PromotionHandler::Cart.new(order_2).activate
        expect(order_2.line_items.flat_map(&:adjustments)).not_to be_empty
      end

      it "does not carry a line item adjustments with the wrong order ID over" do
        subject.merge!(order_2)
        expect(order_1.line_items.flat_map(&:adjustments)).to be_empty
      end
    end
  end

  context "merging together orders with invalid line items" do
    before do
      order_1.contents.add(create(:variant), 1)
      order_2.contents.add(create(:variant), 1)
    end

    it "creates errors with invalid line items" do
      order_2.line_items.first.variant.destroy
      order_2.line_items.reload # so that it registers as invalid
      subject.merge!(order_2)
      expect(order_1.errors.full_messages).not_to be_empty
    end
  end
end
