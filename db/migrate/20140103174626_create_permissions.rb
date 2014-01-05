class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :permissible_type, null: false, limit: 15
      t.integer :permissible_id, null: false
      t.string :action, limit: 20
      t.string :grantee_type, null: false, limit: 15
      t.integer :grantee_id, null: false

      t.timestamps
    end
    add_index :permissions, [:permissible_id, :permissible_type]
    add_index :permissions, [:grantee_type, :grantee_id]
  end
end
