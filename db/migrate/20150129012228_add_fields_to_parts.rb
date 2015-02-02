class AddFieldsToParts < ActiveRecord::Migration
  def change
    add_column :parts, :websites, :text
    add_column :parts, :platform_id, :integer
    add_column :parts, :private, :boolean, default: true
    add_column :parts, :product_tags_string, :string
    change_column :parts, :description, :text
    add_index :parts, :platform_id
  end
end

# delete: quantity, total_cost, vendor_link, partable_type, partable_id, comment