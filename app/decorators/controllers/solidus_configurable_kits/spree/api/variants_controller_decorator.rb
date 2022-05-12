# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module Api
      module VariantsControllerDecorator
        private

        def include_list
          list = [
            { option_values: :option_type },
            { product: :kit_requirements },
#             :default_price,
            :images,
            { stock_items: :stock_location },
          ]
          list.push(:default_price) if Spree.solidus_gem_version <= Gem::Version.new('3')
          list
        end

        ::Spree::Api::VariantsController.prepend self
      end
    end
  end
end
