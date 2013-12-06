class AddPositionToParts < ActiveRecord::Migration
  def change
    add_column :parts, :position, :integer
  end
end
