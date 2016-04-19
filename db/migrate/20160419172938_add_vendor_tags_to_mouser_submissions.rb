class AddVendorTagsToMouserSubmissions < ActiveRecord::Migration
  def change
    add_column :mouser_submissions, :vendor_tags, :string
  end
end
