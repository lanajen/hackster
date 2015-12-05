class AddGenericToParts < ActiveRecord::Migration
  def change
    add_column :parts, :generic, :boolean
  end
end
