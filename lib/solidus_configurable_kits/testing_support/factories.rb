# frozen_string_literal: true

FactoryBot.define do
  factory :kit_requirement, class: SolidusConfigurableKits::Requirement do
    product
    association :required_product, factory: :product

    before(:create) do |kit_requirement|
      kit_requirement.required_product.master.prices << ::Spree::Price.new(currency: "USD", amount: 0, kit_item: true)
    end
  end
end
