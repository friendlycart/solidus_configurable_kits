# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "spree/admin/prices/_table",
  name: "configurable_kits_price_kit_header",
  insert_before: "[data-hook='prices_header'] .actions",
  partial: "solidus_configurable_kits/admin/shared/prices_table_header_addition",
  disabled: false
)

Deface::Override.new(
  virtual_path: "spree/admin/prices/_master_variant_table",
  name: "configurable_kits_price_kit_master_header",
  insert_before: "[data-hook='master_prices_header'] .actions",
  partial: "solidus_configurable_kits/admin/shared/prices_table_header_addition",
  disabled: false
)

Deface::Override.new(
  virtual_path: "spree/admin/prices/_table",
  name: "configurable_kits_price_kit_row",
  insert_before: "[data-hook='prices_row'] .actions",
  partial: "solidus_configurable_kits/admin/shared/prices_table_row_addition",
  disabled: false
)

Deface::Override.new(
  virtual_path: "spree/admin/prices/_master_variant_table",
  name: "configurable_kits_price_kit_master_row",
  insert_before: "[data-hook='prices_row'] .actions",
  partial: "solidus_configurable_kits/admin/shared/prices_table_row_addition",
  disabled: false
)

Deface::Override.new(
  virtual_path: "spree/admin/prices/_form",
  name: "configurable_kits_price_kit_form",
  insert_bottom: "[data-hook='admin_product_price_form']",
  partial: "solidus_configurable_kits/admin/shared/prices_form_addition",
  disabled: false
)
