class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :taggable_id, null: false
      t.string :taggable_type, null: false
      t.string :type, null: false
      t.string :name

      t.timestamps
    end
    add_index :tags, [:taggable_id, :taggable_type, :type], name: 'index_taggable'
  end
end
