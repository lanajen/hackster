class AddOneLinerToParts < ActiveRecord::Migration
  def change
    add_column :parts, :one_liner, :string, limit: 140
  end
end
