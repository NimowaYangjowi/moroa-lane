class CreateChannelEventDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :channel_event_deliveries do |t|
      t.references :event, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true
      t.references :channel_user_mapping, null: true, foreign_key: true
      t.string :member_id, null: false
      t.string :channel_user_id
      t.string :status, null: false, default: "pending"
      t.string :channel_event_id
      t.integer :attempts, null: false, default: 0
      t.text :last_error
      t.datetime :sent_at

      t.timestamps
    end

    add_index :channel_event_deliveries, :event_id, unique: true
    add_index :channel_event_deliveries, [ :status, :created_at ]
    add_index :channel_event_deliveries, :channel_event_id, unique: true, where: "channel_event_id IS NOT NULL"
  end
end
