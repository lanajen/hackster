class CreateReputationEvents < ActiveRecord::Migration
  def change
    create_table :reputation_events do |t|
      t.integer :points
      t.integer :user_id
      t.string :event_name
      t.integer :event_model_id
      t.string :event_model_type
      t.datetime :event_date
    end
    add_index :reputation_events, :user_id
  end
end
