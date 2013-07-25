class CreateReputations < ActiveRecord::Migration
  def change
    create_table :reputations do |t|
      t.integer :points, default: 0
      t.integer :user_id, null: false

      t.timestamps
    end
    add_index :reputations, :user_id
  end
end
