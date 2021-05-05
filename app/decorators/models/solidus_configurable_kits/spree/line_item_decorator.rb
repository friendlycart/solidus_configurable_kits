# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module LineItemDecorator
      def self.prepended(base)
        base.has_many :kit_items,
                      class_name: "Spree::LineItem",
                      foreign_key: :kit_item_id
        base.belongs_to :kit, class_name: "Spree::LineItem", foreign_key: :kit_item_id, optional: true
      end

      def kit_item?
        kit.present?
      end

      ::Spree::LineItem.prepend self
    end
  end
end
