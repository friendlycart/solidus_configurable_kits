class RenameSpreeLineItemsKitItemIdToKitId < ActiveRecord::Migration[5.2]
  def change
    rename_column :spree_line_items, :kit_item_id, :kit_id
  end
end
