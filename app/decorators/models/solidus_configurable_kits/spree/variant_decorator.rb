# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module VariantDecorator
      module ClassMethods
        def with_prices(pricing_options = ::Spree::Config.default_pricing_options)
          query = <<~SQL
            spree_prices.currency = ? AND
              spree_prices.kit_item = ? AND
              (spree_prices.country_iso IS NULL OR spree_prices.country_iso = ?)
          SQL
          where(
            ::Spree::Price
              .where(::Spree::Variant.arel_table[:id].eq(::Spree::Price.arel_table[:variant_id])).
              # This next clause should just be `where(pricing_options.search_arguments)`, but ActiveRecord
              # generates invalid SQL, so the SQL here is written manually.
              where(
                query,
                pricing_options.search_arguments[:currency],
                pricing_options.search_arguments[:kit_item],
                pricing_options.search_arguments[:country_iso].compact
              )
              .arel.exists
          )
        end
      end

      def self.prepended(klass)
        klass.singleton_class.prepend ClassMethods
      end

      def kit_title(pricing_options)
        title = is_master? ? product.name : options_text
        "#{title} (+ #{resilient_money_price(pricing_options)})"
      end

      def resilient_money_price(pricing_options)
        if respond_to?(:price_for_options)
          price_for_options(pricing_options)&.money
        else
          price_for(pricing_options)
        end
      end

      ::Spree::Variant.prepend self
    end
  end
end
