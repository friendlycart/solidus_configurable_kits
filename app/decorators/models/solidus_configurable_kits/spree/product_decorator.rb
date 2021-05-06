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
          joins(variants_including_master: :prices).where(spree_prices: { kit_item: true }).distinct
        }
      end

      ::Spree::Product.prepend self
    end
  end
end
