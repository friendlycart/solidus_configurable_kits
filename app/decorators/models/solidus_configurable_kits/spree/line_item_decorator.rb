# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module LineItemDecorator
      def self.prepended(base)
        base.has_many :kit_items,
          class_name: "Spree::LineItem",
          foreign_key: :kit_id,
          dependent: :destroy,
          inverse_of: :kit
        base.belongs_to :kit,
          class_name: "Spree::LineItem",
          foreign_key: :kit_id,
          optional: true,
          inverse_of: :kit_items
        base.belongs_to :kit_requirement,
          class_name: "::SolidusConfigurableKits::Requirement",
          foreign_key: :requirement_id,
          optional: true
        base.before_validation :update_prices_after_variant_change
        base.before_validation :update_kit_item_quantities
        base.before_validation :create_kit_items
        base.money_methods :kit_total
        base.validate :all_required_kit_items_present
        base.attribute :kit_variant_ids, default: []
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

      private

      def update_prices_after_variant_change
        return unless variant_id_changed?
        self.price = nil
        set_pricing_attributes
      end

      def create_kit_items
        return unless new_record?
        return unless kit?
        return unless kit_variant_ids?.present?

        kit_variant_ids.each do |requirement_id, kit_variant_id|
          kit_items.new(
            requirement_id: requirement_id,
            variant_id: kit_variant_id,
            quantity: quantity,
            order: order
          )
        end
      end

      def update_kit_item_quantities
        return if new_record? || !quantity_changed?

        kit_items.each do |kit_item|
          kit_item.quantity = quantity
          kit_item.save
        end
      end

      def all_required_kit_items_present
        return true unless kit?
        return true if quantity.zero? || required_kit_items_fulfilled?

        errors.add(:kit_items, :do_not_fulfill_product_kit_requirements)
      end

      def required_kit_items_fulfilled?
        required_product_ids == kit_item_product_ids
      end

      def required_product_ids
        Set.new(product.kit_requirements.map(&:required_product_id))
      end

      def kit_item_product_ids
        Set.new(kit_items.map(&:variant).map(&:product_id))
      end

      ::Spree::LineItem.prepend self
    end
  end
end
