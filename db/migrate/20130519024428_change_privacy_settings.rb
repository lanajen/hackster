class ChangePrivacySettings < ActiveRecord::Migration
  def up
    change_column :projects, :private, :boolean, default: false, null: false
    change_column :widgets, :private, :boolean, default: false, null: false
    change_column :stages, :private, :boolean, default: false, null: false
    change_column :widgets, :stage_id, :integer, null: false
  end

  def down
    change_column :projects, :private, :boolean, default: true, null: false
    change_column :widgets, :private, :boolean, default: true, null: false
    change_column :stages, :private, :boolean, default: true, null: false
    change_column :widgets, :stage_id, :integer, null: true
  end
end
