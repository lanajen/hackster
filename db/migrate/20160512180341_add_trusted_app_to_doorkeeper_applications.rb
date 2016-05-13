class AddTrustedAppToDoorkeeperApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :trusted_app, :boolean, default: false
  end
end
