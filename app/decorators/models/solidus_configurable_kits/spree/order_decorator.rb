# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module OrderDecorator
      def self.prepended(base)
        base.register_line_item_comparison_hook :matching_kit_variant_ids
      end

      private

      def matching_kit_variant_ids(line_item, options)
        return false if line_item.kit_item?
        existing_kit_variant_ids = line_item.kit_items.map do |kit_item|
          [kit_item.kit_requirement.id.to_s, kit_item.variant_id.to_s]
        end.to_h
        wanted_kit_variant_ids = (options["kit_variant_ids"] || {})

        existing_kit_variant_ids == wanted_kit_variant_ids
      end

      ::Spree::Order.prepend self
    end
  end
end
