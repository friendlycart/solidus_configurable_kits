# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module LineItemDecorator
      def self.prepended(base)
        base.has_many :kit_items,
          class_name: "Spree::LineItem",
          foreign_key: :kit_item_id,
          dependent: :destroy
        base.belongs_to :kit, class_name: "Spree::LineItem", foreign_key: :kit_item_id, optional: true
        base.before_update :update_kit_item_quantities
        base.money_methods :kit_total
      end

      def kit_item?
        kit.present?
      end

      def kit_total
        amount + kit_items.sum(&:amount)
      end

      def assign_attributes(*)
        return if kit_item?

        super
      end

      private

      def update_kit_item_quantities
        return unless quantity_changed?

        kit_items.each do |kit_item|
          single_kit_item_quantity = kit_item.quantity / quantity_was
          kit_item.quantity = single_kit_item_quantity * quantity
          kit_item.save
        end
      end

      ::Spree::LineItem.prepend self
    end
  end
end
