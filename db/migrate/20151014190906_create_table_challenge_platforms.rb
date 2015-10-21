class CreateTableChallengePlatforms < ActiveRecord::Migration
  def change
    create_table :challenges_groups, id: false do |t|
      t.integer :group_id, null: false
      t.integer :challenge_id, null: false
    end
    add_index :challenges_groups, :challenge_id
    add_index :challenges_groups, :group_id
  end
end
