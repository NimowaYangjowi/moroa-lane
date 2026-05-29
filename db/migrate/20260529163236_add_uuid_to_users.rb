class AddUuidToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :uuid, :string

    User.reset_column_information
    User.find_each do |user|
      user.update_columns(uuid: SecureRandom.uuid)
    end

    change_column_null :users, :uuid, false
    add_index :users, :uuid, unique: true
  end

  def down
    remove_index :users, :uuid
    remove_column :users, :uuid
  end
end
