class CreatePrivacySettings < ActiveRecord::Migration
  def change
    add_column :projects, :private, :boolean, default: true, null: false
    add_index :projects, :private
    add_column :widgets, :private, :boolean, default: true, null: false
    add_index :widgets, :private
    add_column :stages, :private, :boolean, default: true, null: false
    add_index :stages, :private
  end
end
