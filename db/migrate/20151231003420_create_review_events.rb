class CreateReviewEvents < ActiveRecord::Migration
  def change
    create_table :review_events do |t|
      t.integer :user_id, null: false, default: 0
      t.integer :review_thread_id, null: false
      t.string :event
      t.hstore :meta

      t.timestamps null: false
    end
    add_index :review_events, :user_id
    add_index :review_events, :review_thread_id
  end
end
