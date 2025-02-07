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
        base.money_methods :kit_total
        base.validate :all_required_kit_items_present
      end

      def kit_item?
        kit_requirement.present?
      end

      def kit_total
        amount + kit_items.sum(&:amount)
      end

      def kit?
        variant&.product&.kit_requirements&.any? || false
      end

      def serializable_hash
        super.tap do |hash|
          hash["kit_variant_ids"] = kit_variant_ids
        end
      end

      def kit_variant_ids
        kit_items.map do |kit_item|
          [kit_item.kit_requirement.id.to_s, kit_item.variant_id.to_s]
        end.to_h
      end

      def kit_variant_ids=(hash)
        hash.each do |requirement_id, kit_variant_id|
          next if kit_variant_id.blank?

          kit_items.new(
            requirement_id: requirement_id,
            variant_id: kit_variant_id,
            quantity: quantity,
            order: order
          )
        end
      end

      private

      def update_prices_after_variant_change
        return unless variant_id_changed?
        return unless variant

        self.price = nil
        set_pricing_attributes
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
        return true if quantity.zero?
        return true if required_kit_items_fulfilled? && only_allowed_products_in_kit?

        errors.add(:kit_items, :do_not_fulfill_product_kit_requirements)
      end

      def required_kit_items_fulfilled?
        (required_product_ids - kit_item_product_ids).empty?
      end

      def only_allowed_products_in_kit?
        (kit_item_product_ids - product.kit_requirements.map(&:required_product_id)).empty?
      end

      def required_product_ids
        product.kit_requirements.reject(&:optional).map(&:required_product_id).sort
      end

      def kit_item_product_ids
        kit_items.map(&:variant).map(&:product_id).sort
      end

      ::Spree::LineItem.prepend self
    end
  end
end
