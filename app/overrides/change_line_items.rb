# frozen_string_literal: false

Deface::Override.new(
  virtual_path: "spree/orders/_form",
  name: "configurable_kits_cart_items",
  replace_contents: "#line_items",
  partial: "solidus_configurable_kits/shared/line_item_override",
  disabled: false
)
