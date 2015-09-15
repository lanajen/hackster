class CreateChallengeProjectsPrizes < ActiveRecord::Migration
  def change
    create_table :challenge_projects_prizes do |t|
      t.integer :challenge_entry_id
      t.integer :prize_id
    end
  end
end
