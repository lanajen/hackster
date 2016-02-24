class CreateReviewDecisions < ActiveRecord::Migration
  def change
    create_table :review_decisions do |t|
      t.integer :user_id, null: false
      t.string :decision
      t.hstore :feedback
      t.boolean :approved
      t.integer :review_thread_id, null: false

      t.timestamps null: false
    end
    add_index :review_decisions, :user_id
    add_index :review_decisions, :review_thread_id
  end
end
