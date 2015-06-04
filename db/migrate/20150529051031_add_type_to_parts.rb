class AddTypeToParts < ActiveRecord::Migration
  def change
    add_column :parts, :type, :string, limit: 15, default: 'HardwarePart'
  end
end
