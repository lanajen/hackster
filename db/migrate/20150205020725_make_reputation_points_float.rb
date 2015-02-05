class MakeReputationPointsFloat < ActiveRecord::Migration
  def change
    change_column :reputations, :points, :float
  end
end
