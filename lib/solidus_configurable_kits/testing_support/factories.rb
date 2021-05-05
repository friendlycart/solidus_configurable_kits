# frozen_string_literal: true

FactoryBot.define do
  factory :kit_requirement, class: SolidusConfigurableKits::Requirement do
    product
    association :required_product, factory: :product
  end
end
