class AddLastEditedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :last_edited_at, :datetime
  end
end
