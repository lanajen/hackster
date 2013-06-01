class AddPositionToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :position, :string, default: '', null: false
    add_index :widgets, :position
  end
end
