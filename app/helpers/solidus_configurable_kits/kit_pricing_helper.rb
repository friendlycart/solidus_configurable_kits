# frozen_string_literal: true

module SolidusConfigurableKits
  module KitPricingHelper
    def current_kit_pricing_options
      SolidusConfigurableKits::PricingOptions.from_context(
        self, kit_item: true
      )
    end
  end
end
