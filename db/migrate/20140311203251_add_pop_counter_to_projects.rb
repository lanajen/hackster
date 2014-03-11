class AddPopCounterToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :popularity_counter, :integer, default: 0
  end
end
