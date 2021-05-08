# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module Api
      module VariantsControllerDecorator
        private

        def include_list
          [
            { option_values: :option_type },
            { product: :kit_requirements },
            :default_price,
            :images,
            { stock_items: :stock_location },
          ]
        end

        ::Spree::Api::VariantsController.prepend self
      end
    end
  end
end
