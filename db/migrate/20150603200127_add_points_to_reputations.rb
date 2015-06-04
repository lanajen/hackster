class AddPointsToReputations < ActiveRecord::Migration
  def change
    add_column :reputations, :redeemed_points, :integer, default: 0
    add_column :reputations, :redeemable_points, :integer, default: 0
  end
end
