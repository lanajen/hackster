class AddStaticCountersToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :projects_count, :integer
    add_column :groups, :members_count, :integer
  end
end
