class CreateSolidusConfigurableKitsRequirements < ActiveRecord::Migration[5.2]
  def change
    create_table :solidus_configurable_kits_requirements do |t|
      t.references :product, type: :integer, null: false, foreign_key: { to_table: :spree_products },
        index: { name: :index_solidus_kit_products }
      t.references :required_product, type: :integer, null: false, foreign_key: { to_table: :spree_products },
        index: { name: :index_solidus_kit_requirements }
      t.string :name
      t.text :description
      t.integer :quantity, default: 1, null: false

      t.timestamps
    end
  end
end
