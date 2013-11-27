class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.string :uid, null: false, limit: 100
      t.string :provider, null: false, limit: 50
      t.integer :user_id, null: false
      t.string :name
      t.string :link

      t.timestamps
    end
    add_index :authorizations, :user_id
    add_index :authorizations, [:provider, :uid]
  end
end
