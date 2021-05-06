# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusConfigurableKits
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace SolidusConfigurableKits

    engine_name 'solidus_configurable_kits'

    initializer 'solidus_configurable_kits.include_kit_pricing_helper' do
      ::ActionView::Base.include SolidusConfigurableKits::KitPricingHelper
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
