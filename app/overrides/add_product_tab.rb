# frozen_string_literal: false

Deface::Override.new(virtual_path: "spree/admin/shared/_product_tabs",
                     name: "configurable_kits_admin_product_tabs",
                     insert_bottom: "[data-hook='admin_product_tabs']",
                     partial: "solidus_configurable_kits/shared/configurable_kits_product_tab",
                     disabled: false)
