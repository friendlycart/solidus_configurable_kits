# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module ProductDecorator
      def self.prepended(base)
        base.has_many :kit_requirements,
          class_name: "SolidusConfigurableKits::Requirement",
          foreign_key: :product_id
        base.has_many :kits, through: :kit_requirements, source: :product
        base.has_many :required_kit_products, through: :kit_requirements, source: :required_product
        base.delegate :resilient_money_price, to: :master

        base.scope :with_kit_item_prices, -> {
          joins(variants_including_master: :prices).where(spree_prices: {kit_item: true}).distinct
        }
      end

      # @param pricing_options [Spree::Variant::PricingOptions] the pricing options to search
      #   for, default: the default pricing options
      # @return [Array<Spree::Variant>] all variants that can be part of a kit
      def kit_item_variants_for(pricing_options = Spree::Config.default_pricing_options)
        variants_including_master.includes(:option_values).with_prices(pricing_options).select do |variant|
          variant.option_values.any? || (variant.is_master? && variants.none?)
        end
      end

      ::Spree::Product.prepend self
    end
  end
end
