class CleanupWidgets < ActiveRecord::Migration
  def up
    remove_column :widgets, :stage_id
    remove_column :widgets, :completion_rate
    remove_column :widgets, :completion_share
    remove_column :widgets, :private
  end
end
