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

        line_item.kit_variant_ids == (options["kit_variant_ids"] || {})
      end

      ::Spree::Order.prepend self
    end
  end
end
