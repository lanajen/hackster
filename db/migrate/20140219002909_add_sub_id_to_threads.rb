class AddSubIdToThreads < ActiveRecord::Migration
  def change
    add_column :threads, :sub_id, :integer, null: false, default: 0
    add_index :threads, [:sub_id, :threadable_id, :threadable_type], name: 'threadable_sub_ids'
  end
end
