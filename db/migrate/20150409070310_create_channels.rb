class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.integer :group_id
      t.text :cache_counters
      t.boolean :restricted

      t.timestamps null: false
    end
  end
end
