class CreateInviteCodes < ActiveRecord::Migration
  def change
    create_table :invite_codes do |t|
      t.string :code, limit: 20
      t.integer :limit
      t.boolean :active, default: true

      t.timestamps
    end
    add_column :users, :invite_code_id, :integer
  end
end
