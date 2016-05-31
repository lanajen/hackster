class AddCreatedAtIndicesToImpressionsTables < ActiveRecord::Migration
  def change
    add_index :impressions, :created_at, name: "impressions_created_at_idx"
    add_index :group_impressions, :created_at, name: "group_impressions_created_at_idx"
    add_index :project_impressions, :created_at, name: "project_impressions_created_at_idx"
    add_index :part_impressions, :created_at, name: "part_impressions_created_at_idx"
  end
end
