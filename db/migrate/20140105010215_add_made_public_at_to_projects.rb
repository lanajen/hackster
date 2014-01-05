class AddMadePublicAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :made_public_at, :datetime
    Project.where(private: false).each do |project|
      project.made_public_at = project.created_at
      project.save
    end
  end
end
