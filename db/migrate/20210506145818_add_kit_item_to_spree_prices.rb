class AddKitItemToSpreePrices < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_prices, :kit_item, :boolean, default: false, null: false
  end
end
