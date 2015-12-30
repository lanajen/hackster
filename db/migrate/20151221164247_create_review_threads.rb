class CreateReviewThreads < ActiveRecord::Migration
  def change
    create_table :review_threads do |t|
      t.integer :project_id, null: false
      t.string :workflow_state
      t.boolean :locked, default: false

      t.timestamps null: false
    end
    add_index :review_threads, :project_id
  end
end
