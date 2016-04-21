class CreateMouserSubmissions < ActiveRecord::Migration
  def change
    create_table :mouser_submissions do |t|
      t.string :workflow_state
      t.integer :user_id, null: false
      t.integer :project_id
      t.string :vendor_user_name, null: false
      t.timestamps null: false
    end
    add_index :mouser_submissions, :vendor_user_name
    add_index :mouser_submissions, :user_id
  end
end