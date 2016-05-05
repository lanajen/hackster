class CleanImpressionsTable < ActiveRecord::Migration
  def up
    remove_column :impressions, :user_id
    remove_column :impressions, :controller_name
    remove_column :impressions, :action_name
    remove_column :impressions, :view_name
    remove_column :impressions, :request_hash
    remove_column :impressions, :ip_address
    remove_column :impressions, :referrer
    remove_column :impressions, :updated_at
    change_column :impressions, :impressionable_id, :integer, null: false
    change_column :impressions, :impressionable_type, :string, null: false
    remove_index :impressions, name: "impressionable_type_message_index"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end