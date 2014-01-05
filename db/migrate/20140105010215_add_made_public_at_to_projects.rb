class AddMadePublicAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :made_public_at, :datetime
    Project.live.each do |project|
      project.made_public_at = project.created_at
      project.save
    end
  end
end
