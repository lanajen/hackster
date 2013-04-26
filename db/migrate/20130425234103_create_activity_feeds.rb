class CreateActivityFeeds < ActiveRecord::Migration
  def change
    create_table :broadcasts do |t|
      t.string :broadcastable_type, null: false
      t.integer :broadcastable_id, null: false
      t.string :event, null: false
      t.integer :context_model_id, null: false
      t.string :context_model_type, null: false

      t.timestamps
    end
    add_index :broadcasts, [:broadcastable_type, :broadcastable_id], name: 'index_broadcastable'
    add_index :broadcasts, [:context_model_type, :context_model_id], name: 'index_broadcasted'
  end
end
