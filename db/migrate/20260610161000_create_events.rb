class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.references :user, null: true, foreign_key: true, index: false
      t.references :subject, polymorphic: true, null: true, index: false
      t.json :properties, null: false, default: {}
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :events, [ :name, :occurred_at ]
    add_index :events, [ :user_id, :occurred_at ]
    add_index :events, [ :subject_type, :subject_id, :occurred_at ]
  end
end
