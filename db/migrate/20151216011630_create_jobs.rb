class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :url
      t.string :title
      t.string :employer_name
      t.string :location
      t.integer :platform_id
      t.string :workflow_state
      t.integer :clicks_count, default: 0

      t.timestamps null: false
    end
    add_index :jobs, :platform_id
  end
end
