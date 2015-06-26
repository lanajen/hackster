class ChangeDefaultForParts < ActiveRecord::Migration
  def change
    change_column :parts, :private, :boolean, default: false
  end
end

# Part.update_all private: false