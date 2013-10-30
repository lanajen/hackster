class AddCounterCacheToProjectsAndUsers < ActiveRecord::Migration
  def change
    add_column :users, :impressions_count, :integer, default: 0
    add_column :projects, :impressions_count, :integer, default: 0
  end
end
