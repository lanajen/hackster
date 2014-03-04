class ChangeBroadcastable < ActiveRecord::Migration
  def change
    add_column :broadcasts, :user_id, :integer
    add_column :broadcasts, :project_id, :integer
  end
end
