class CreateChallengeRegistrations < ActiveRecord::Migration
  def change
    create_table :challenge_registrations do |t|
      t.integer :user_id, null: false
      t.integer :challenge_id, null: false

      t.timestamps null: false
    end
    add_index :challenge_registrations, :user_id
    add_index :challenge_registrations, :challenge_id
  end
end
