class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false
      t.integer :total_cents, null: false
      t.datetime :placed_at, null: false

      t.timestamps
    end
  end
end
