# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module OrderDecorator
       def self.prepended(base)
        base.register_line_item_comparison_hook :never_match_kit_items
      end

      private

      def never_match_kit_items(line_item, _options)
        !line_item.kit_item?
      end

      ::Spree::Order.prepend self
    end
  end
end
