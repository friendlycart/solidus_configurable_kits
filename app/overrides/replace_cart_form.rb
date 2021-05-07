# frozen_string_literal: false

Deface::Override.new(
  virtual_path: "spree/products/show",
  name: "configurable_kits_kit_form",
  surround: "[data-hook='cart_form']",
  partial: "solidus_configurable_kits/shared/kit_cart_form",
  disabled: false
)
