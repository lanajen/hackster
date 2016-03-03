class CreateTablePartsPlatforms < ActiveRecord::Migration
  def change
    create_table :parts_platforms do |t|
      t.integer :part_id, null: false
      t.integer :platform_id, null: false
    end
    add_index :parts_platforms, :part_id
    add_index :parts_platforms, :platform_id
  end
end
