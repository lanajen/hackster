class AddGuestNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :guest_name, :string, limit: 128
  end
end
