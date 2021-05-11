# frozen_string_literal: false

Deface::Override.new(
  virtual_path: "spree/checkout/_delivery",
  name: "kit_manifest_on_delivery_page",
  replace_contents: ".shipment .stock-contents .item-price",
  partial: "solidus_configurable_kits/shared/kit_manifest_item_price",
  disabled: false
)
