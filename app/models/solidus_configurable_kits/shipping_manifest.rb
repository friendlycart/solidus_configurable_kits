# frozen_string_literal: true

module SolidusConfigurableKits
  class ShippingManifest < ::Spree::ShippingManifest
    def items
      grouped_by_kit = super.group_by { |manifest_item| manifest_item.line_item.kit }
      kit_manifest_items = grouped_by_kit.keys.compact
      result = []
      kit_manifest_items.each do |kit_line_item|
        result += [grouped_by_kit[nil].detect{ |i| i.line_item = kit_line_item }]
        result += grouped_by_kit[kit_line_item]
      end
      result += grouped_by_kit[nil].reject { |manifest_item| manifest_item.line_item.kit? }
    end
  end
end
