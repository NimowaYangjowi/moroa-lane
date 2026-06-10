class CreateChannelUserMappings < ActiveRecord::Migration[8.1]
  def change
    create_table :channel_user_mappings do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :member_id, null: false
      t.string :channel_user_id
      t.datetime :synced_at
      t.text :last_error

      t.timestamps
    end

    add_index :channel_user_mappings, :user_id, unique: true
    add_index :channel_user_mappings, :member_id, unique: true
    add_index :channel_user_mappings, :channel_user_id, unique: true, where: "channel_user_id IS NOT NULL"
  end
end
