class ChangeParts < ActiveRecord::Migration
  def up
    add_column :parts, :mpn, :string
    add_column :parts, :description, :string
  end

  def down
  end
end
