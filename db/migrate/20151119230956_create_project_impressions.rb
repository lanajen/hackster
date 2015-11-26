class CreateProjectImpressions < ActiveRecord::Migration
  def change
    create_table :project_impressions do |t|
      t.belongs_to :project, foreign_key: true, null: false
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
    add_index :project_impressions, [:controller_name,:action_name,:request_hash], :name => "pi_controlleraction_request_index", :unique => false
    add_index :project_impressions, [:controller_name,:action_name,:ip_address], :name => "pi_controlleraction_ip_index", :unique => false
    add_index :project_impressions, [:controller_name,:action_name,:session_hash], :name => "pi_controlleraction_session_index", :unique => false
    add_index :project_impressions, :user_id
  end
end
