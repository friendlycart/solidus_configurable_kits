class AddRequirementIdToSpreeLineItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :spree_line_items,
                  :requirement,
                  foreign_key: { to_table: :solidus_configurable_kits_requirements },
                  index: { name: :index_line_items_requirement }
  end
end
