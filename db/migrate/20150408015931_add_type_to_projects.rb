class AddTypeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :type, :string, default: 'Project', null: false, limit: 15
    add_index :projects, :type
  end
end

# Project.where(external: true).update_all(type: 'ExternalProject')