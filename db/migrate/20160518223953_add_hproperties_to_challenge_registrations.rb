class AddHpropertiesToChallengeRegistrations < ActiveRecord::Migration
  def change
    add_column :challenge_registrations, :hproperties, :hstore
  end
end
