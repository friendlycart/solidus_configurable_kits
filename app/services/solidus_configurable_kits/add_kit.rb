# frozen_string_literal: true

module SolidusConfigurableKits
  class AddKit
    attr_reader :order

    def initialize(order)
      @order = order
    end

    def call(variant, quantity, kit_variants)
      line_item = order.contents.add(variant, quantity)

      kit_variants.each do |kit_variant|
        order.contents.add(kit_variant, quantity)
      end

      line_item
    end
  end
end
