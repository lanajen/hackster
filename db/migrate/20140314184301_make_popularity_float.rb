class MakePopularityFloat < ActiveRecord::Migration
  def change
    change_column :projects, :popularity_counter, :float, default: 0
  end
end
