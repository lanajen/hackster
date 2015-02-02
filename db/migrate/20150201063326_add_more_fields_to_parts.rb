class AddMoreFieldsToParts < ActiveRecord::Migration
  def change
    add_column :parts, :counters_cache, :text
    add_column :parts, :workflow_state, :string
  end
end
