class CreateGroupImpressions < ActiveRecord::Migration
  def change
    create_table :group_impressions do |t|
      t.belongs_to :group, foreign_key: true, null: false
      t.integer :user_id
      t.string :controller_name
      t.string :action_name
      t.string :view_name
      t.string :request_hash
      t.string :ip_address
      t.string :session_hash
      t.text :message
      t.text :referrer
      t.timestamps null: false
    end
    # add_index :group_impressions, [:group_id, :session_hash], :name => "gi_group_session_index", :unique => false
    # add_index :group_impressions, :group_id
  end
end
