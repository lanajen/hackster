class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer :user_id, null: false
      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    add_index :projects, :user_id
  end
end
