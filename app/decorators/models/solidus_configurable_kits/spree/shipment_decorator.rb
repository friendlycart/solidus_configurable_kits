# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module ShipmentDecorator
      def manifest
        @manifest ||= SolidusConfigurableKits::ShippingManifest.new(inventory_units: inventory_units).items
      end

      ::Spree::Shipment.prepend self
    end
  end
end
