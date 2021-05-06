# frozen_string_literal: true

module SolidusConfigurableKits
  module KitPricingHelper
    def current_kit_pricing_options
      ::Spree::Config.pricing_options_class.from_context(self, kit_item: true)
    end
  end
end
