class CreateChallengeIdeas < ActiveRecord::Migration
  def change
    create_table :challenge_ideas do |t|
      t.integer :challenge_id
      t.integer :user_id
      t.string :name
      t.hstore :properties
      t.string :workflow_state

      t.timestamps null: false
    end
  end
end
