class CreateTeams < ActiveRecord::Migration
  def change
    # users can be part of multiple teams. Projects and teams are the same
    create_table :team_members do |t|
      t.integer :user_id, null: false
      t.integer :project_id, null: false
      t.string :role

      t.timestamps
    end
    add_index :team_members, :user_id
    add_index :team_members, :project_id

#    # each team has one project
#    create_table :teams do |t|
#      t.integer :project_id, null: false
#
#      t.timestamps
#    end
#    add_index :teams, :project_id

#    # teams can have multiple projects
#    create_table :projects_teams do |t|
#      t.integer :project_id, null: false
#      t.integer :team_id, null: false
#
#      t.timestamps
#    end
#    add_index :projects_teams, :project_id
#    add_index :projects_teams, :team_id
  end
end
