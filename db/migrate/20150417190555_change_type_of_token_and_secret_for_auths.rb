class ChangeTypeOfTokenAndSecretForAuths < ActiveRecord::Migration
  def change
    change_column :authorizations, :token, :text
    change_column :authorizations, :secret, :text
  end
end
