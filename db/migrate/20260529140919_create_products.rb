class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :category, null: false
      t.text :description, null: false
      t.integer :price_cents, null: false
      t.string :image_url, null: false
      t.string :skin_type, null: false
      t.boolean :featured, null: false, default: false

      t.timestamps
    end

    add_index :products, :slug, unique: true
  end
end
