class AddAccessTokenToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :token, :string
    add_column :authorizations, :secret, :string
  end
end
