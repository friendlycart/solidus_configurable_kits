class AddKitItemIdToSpreeLineItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :spree_line_items, :kit_item, foreign_key: { to_table: :spree_line_items },
      index: { name: :index_line_item_kit_items }
  end
end
