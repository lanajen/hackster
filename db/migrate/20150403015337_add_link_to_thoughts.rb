class AddLinkToThoughts < ActiveRecord::Migration
  def change
    add_column :thoughts, :link, :string
    # add_column :thoughts, :cached_link_properties, :text
    add_column :thoughts, :raw_body, :text
  end
end
