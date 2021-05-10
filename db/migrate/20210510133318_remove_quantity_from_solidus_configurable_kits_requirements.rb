class RemoveQuantityFromSolidusConfigurableKitsRequirements < ActiveRecord::Migration[5.2]
  def change
    remove_column :solidus_configurable_kits_requirements, :quantity, default: 1, null: false
  end
end
