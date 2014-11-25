class AddLevelToAwardedBadges < ActiveRecord::Migration
  def change
    add_column :awarded_badges, :level, :string
  end
end
