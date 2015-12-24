class AddAddressIdToChallengeIdeas < ActiveRecord::Migration
  def change
    add_column :challenge_ideas, :address_id, :integer
  end
end
