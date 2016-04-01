class AddPropertiesToChallengeEntries < ActiveRecord::Migration
  def change
    add_column :challenge_projects, :properties, :hstore
  end
end
