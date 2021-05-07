# frozen_string_literal: true

module SolidusConfigurableKits
  class Requirement < ::Spree::Base
    belongs_to :product, class_name: "Spree::Product", inverse_of: :kit_requirements
    belongs_to :required_product, class_name: "Spree::Product", inverse_of: :kits

    validate :required_product_has_kit_item_prices

    private

    def required_product_has_kit_item_prices
      return if required_product&.prices&.where(kit_item: true)&.any?

      errors.add(:required_product, :needs_at_least_one_variant_with_a_kit_price)
    end
  end
end
