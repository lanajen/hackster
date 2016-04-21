class CreateMouserSubmissions < ActiveRecord::Migration
  def change
    create_table :mouser_submissions do |t|
      t.string :status
      t.string :project_name
      t.integer :user_id
      t.integer :project_id
      t.integer :vendor_id
      t.timestamps null: false
    end
  end
end