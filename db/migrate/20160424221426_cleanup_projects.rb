class CleanupProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :start_date
    remove_column :projects, :end_date
    remove_column :projects, :collection_id
    remove_column :projects, :wip
    remove_column :projects, :layout
    remove_column :projects, :external
    remove_column :projects, :open_source
    remove_column :projects, :buy_link
    remove_column :projects, :story
  end
end