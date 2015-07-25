class Cleanup < ActiveRecord::Migration
  def up
    drop_table :broadcasts if ActiveRecord::Base.connection.table_exists? :broadcasts
    drop_table :group_relations if ActiveRecord::Base.connection.table_exists? :group_relations
    drop_table :invite_requests if ActiveRecord::Base.connection.table_exists? :invite_requests
    drop_table :invite_codes if ActiveRecord::Base.connection.table_exists? :invite_codes
    drop_table :monologue_posts if ActiveRecord::Base.connection.table_exists? :monologue_posts
    drop_table :monologue_taggings if ActiveRecord::Base.connection.table_exists? :monologue_taggings
    drop_table :team_members if ActiveRecord::Base.connection.table_exists? :team_members
    drop_table :videos if ActiveRecord::Base.connection.table_exists? :videos
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
