# frozen_string_literal: true

json.cache! [I18n.locale, line_item] do
  json.call(line_item, *line_item_attributes)
  json.single_display_amount(line_item.single_display_amount.to_s)
  json.display_amount(line_item.display_amount.to_s)
  json.total(line_item.total)
  json.variant do
    json.partial!("spree/api/variants/small", variant: line_item.variant)
    json.call(line_item.variant, :product_id)
    json.images(line_item.variant.gallery.images) do |image|
      json.partial!("spree/api/images/image", image: image)
    end
  end
  json.adjustments(line_item.adjustments) do |adjustment|
    json.partial!("spree/api/adjustments/adjustment", adjustment: adjustment)
  end
  if line_item.kit_requirement
    json.kit_requirement do
      json.id line_item.kit_requirement.id
      json.name line_item.kit_requirement.name
      json.required_product_id line_item.kit_requirement.required_product_id
    end
  end
  json.kit do |_kit|
    json.partial!("spree/api/line_items/line_item", line_item: line_item.kit) if line_item.kit
  end
end
