class ChangeLicenseForProject < ActiveRecord::Migration
  def change
    change_column :projects, :license, :string, limit: 100
  end
end
