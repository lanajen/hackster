class AddDefaultToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :default, :boolean, default: false
    add_column :addresses, :deleted, :boolean, default: false
  end
end
