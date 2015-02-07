class AddSlugToParts < ActiveRecord::Migration
  def change
    add_column :parts, :slug, :string
  end
end
