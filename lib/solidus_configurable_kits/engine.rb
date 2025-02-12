# frozen_string_literal: true

require "solidus_core"
require "solidus_support"

module SolidusConfigurableKits
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace SolidusConfigurableKits

    engine_name "solidus_configurable_kits"

    initializer "solidus_configurable_kits.add_permitted_attribute" do
      ::Spree::PermittedAttributes.line_item_attributes << {kit_variant_ids: {}}
    end

    initializer "solidus_configurable_kits.set_default_classes" do
      Spree.config do |config|
        config.variant_price_selector_class = "SolidusConfigurableKits::PriceSelector"
        config.order_merger_class = "SolidusConfigurableKits::OrderMerger"
      end
    end

    class << self
      def activate
        ActionView::Base.include SolidusConfigurableKits::KitPricingHelper
      end
    end

    config.to_prepare(&method(:activate).to_proc)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
