# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module LineItemDecorator
      def self.prepended(base)
        base.has_many :kit_items,
          class_name: "Spree::LineItem",
          foreign_key: :kit_item_id,
          dependent: :destroy,
          inverse_of: :kit
        base.belongs_to :kit, class_name: "Spree::LineItem", foreign_key: :kit_item_id, optional: true, inverse_of: :kit_items
        base.before_validation :update_kit_item_quantities
        base.money_methods :kit_total
        base.validate :all_required_kit_items_present
      end

      def kit_item?
        kit.present?
      end

      def kit_total
        amount + kit_items.sum(&:amount)
      end

      def kit?
        variant&.product&.kit_requirements&.any? || false
      end

      def assign_attributes(*)
        return if kit_item?

        super
      end

      private

      def update_kit_item_quantities
        return if new_record? || !quantity_changed?

        kit_items.each do |kit_item|
          single_kit_item_quantity = kit_item.quantity / quantity_was
          kit_item.quantity = single_kit_item_quantity * quantity
          kit_item.save
        end
      end

      def all_required_kit_items_present
        return true unless kit?
        return true if quantity.zero?

        if !required_kit_items_fulfilled?
          errors.add(:kit_items, :do_not_fulfill_product_kit_requirements)
        end
      end

      def required_kit_items_fulfilled?
        required_products_and_quantities == kit_item_products_and_quantities
      end

      def required_products_and_quantities
        product.kit_requirements.map { |kr| [kr.required_product_id, kr.quantity * quantity] }.to_h
      end

      def kit_item_products_and_quantities
        kit_items.flat_map { |kit_item| [kit_item.product.id] * kit_item.quantity }.
          group_by(&:itself).
          transform_values(&:length)
      end

      ::Spree::LineItem.prepend self
    end
  end
end
