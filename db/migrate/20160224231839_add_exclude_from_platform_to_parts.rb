class AddExcludeFromPlatformToParts < ActiveRecord::Migration
  def change
    add_column :parts, :exclude_from_platform, :boolean, default: false
    add_index :parts, :exclude_from_platform
  end
end
