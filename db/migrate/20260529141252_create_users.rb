class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :customer_tier, null: false, default: "New"
      t.string :skin_type, null: false, default: "Not selected"

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end
