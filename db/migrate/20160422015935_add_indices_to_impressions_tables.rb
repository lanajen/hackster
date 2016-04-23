class AddIndicesToImpressionsTables < ActiveRecord::Migration
  def change
    add_index :group_impressions, :group_id
    add_index :group_impressions, :session_hash
    remove_column :group_impressions, :user_id
    remove_column :group_impressions, :controller_name
    remove_column :group_impressions, :action_name
    remove_column :group_impressions, :view_name
    remove_column :group_impressions, :request_hash
    remove_column :group_impressions, :ip_address
    remove_column :group_impressions, :referrer
    remove_column :group_impressions, :updated_at

    add_index :part_impressions, :part_id
    add_index :part_impressions, :session_hash
    remove_column :part_impressions, :user_id
    remove_column :part_impressions, :controller_name
    remove_column :part_impressions, :action_name
    remove_column :part_impressions, :view_name
    remove_column :part_impressions, :request_hash
    remove_column :part_impressions, :ip_address
    remove_column :part_impressions, :referrer
    remove_column :part_impressions, :updated_at

    add_index :project_impressions, :project_id
    add_index :project_impressions, :session_hash
    remove_column :project_impressions, :user_id
    remove_column :project_impressions, :controller_name
    remove_column :project_impressions, :action_name
    remove_column :project_impressions, :view_name
    remove_column :project_impressions, :request_hash
    remove_column :project_impressions, :ip_address
    remove_column :project_impressions, :referrer
    remove_column :project_impressions, :updated_at
  end
end
