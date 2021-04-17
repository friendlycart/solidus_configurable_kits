# frozen_string_literal: true

module SolidusConfigurableKits
  class Requirement < ::Spree::Base
    belongs_to :product, class_name: "Spree::Product", inverse_of: :kit_requirements
    belongs_to :required_product, class_name: "Spree::Product", inverse_of: :kits
  end
end
