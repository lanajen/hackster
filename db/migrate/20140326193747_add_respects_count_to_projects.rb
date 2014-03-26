class AddRespectsCountToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :respects_count, :integer, default: 0
  end
end
