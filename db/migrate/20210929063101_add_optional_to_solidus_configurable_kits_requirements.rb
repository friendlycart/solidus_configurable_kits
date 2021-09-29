# frozen_string_literal: true

class AddOptionalToSolidusConfigurableKitsRequirements < ActiveRecord::Migration[5.2]
  def change
    add_column :solidus_configurable_kits_requirements, :optional, :boolean, default: false, null: false
  end
end
