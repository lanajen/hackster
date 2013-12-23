class AddLicenseToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :license, :string, limit: 50
  end
end
