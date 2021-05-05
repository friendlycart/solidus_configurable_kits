# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "spree/products/_cart_form",
  name: "configurable_kits_add_to_cart_additions",
  insert_top: "[data-hook='inside_product_cart_form']",
  partial: "solidus_configurable_kits/shared/configurable_kits_add_to_cart_additions",
  disabled: false
)
