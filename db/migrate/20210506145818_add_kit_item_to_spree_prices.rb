class AddKitItemToSpreePrices < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_prices, :kit_item, :boolean, default: false, null: false
  end
end
