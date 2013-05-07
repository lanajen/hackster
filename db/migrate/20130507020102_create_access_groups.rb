class CreateAccessGroups < ActiveRecord::Migration
  def change
    create_table :access_groups do |t|
      t.integer :project_id
      t.string :name

      t.timestamps
    end
  end
end
