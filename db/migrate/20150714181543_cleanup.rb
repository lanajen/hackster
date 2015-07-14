class Cleanup < ActiveRecord::Migration
  # irreversible migration
  def up
    drop_table :broadcasts
    drop_table :group_relations
    drop_table :invite_requests
    drop_table :invite_codes
    drop_table :monologue_posts
    drop_table :monologue_taggings
    drop_table :team_members
    drop_table :videos
  end
end
