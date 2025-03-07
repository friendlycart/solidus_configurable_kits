# frozen_string_literal: true

json.cache! [I18n.locale, Spree::StockLocation.accessible_by(current_ability), variant] do
  json.call(variant, *variant_attributes)
  json.partial!("spree/api/variants/small", variant: variant)
  json.variant_properties(variant.variant_properties) do |variant_property|
    json.call(variant_property, *variant_property_attributes)
  end
  json.stock_items(variant.stock_items.accessible_by(current_ability)) do |stock_item|
    json.call(stock_item, :id, :count_on_hand, :stock_location_id, :backorderable)
    json.available stock_item.available?
    json.stock_location_name(stock_item.stock_location.name)
  end
  json.kit_requirements variant.product.kit_requirements do |kit_requirement|
    json.id kit_requirement.id
    json.name kit_requirement.name
    json.required_product_id kit_requirement.required_product_id
  end
end
