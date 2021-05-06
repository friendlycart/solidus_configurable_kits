# frozen_string_literal: true

module SolidusConfigurableKits
  class PricingOptions < ::Spree::Variant::PricingOptions
    def self.default_price_attributes
      {
        currency: ::Spree::Config.currency,
        country_iso: ::Spree::Config.admin_vat_country_iso,
        kit_item: false
      }
    end

    def self.from_line_item(line_item)
      tax_address = line_item.order&.tax_address
      new(
        currency: line_item.currency || ::Spree::Config.currency,
        country_iso: tax_address && tax_address.country&.iso,
        kit_item: line_item.kit_item?
      )
    end

    def self.from_price(price)
      new(
        currency: price.currency,
        country_iso: price.country_iso,
        kit_item: price.kit_item
      )
    end

    def self.from_context(context, kit_item = false)
      new(
        currency: context.current_store&.default_currency.presence || ::Spree::Config[:currency],
        country_iso: context.current_store&.cart_tax_country_iso.presence,
        kit_item: kit_item
      )
    end

    def kit_item?
      desired_attributes(:kit_item)
    end
  end
end
