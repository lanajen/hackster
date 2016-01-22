class AddVirtualToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :virtual, :boolean, default: false
  end
end
