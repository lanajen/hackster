class AddDescriptionEditedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :description_edited_at, :datetime
  end
end
