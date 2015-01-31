class AddPropertiesToSubdomains < ActiveRecord::Migration
  def change
    add_column :subdomains, :properties, :text
  end
end
