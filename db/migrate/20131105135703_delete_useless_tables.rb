class DeleteUselessTables < ActiveRecord::Migration
  def up
    %w(participant_invites publications quotes searches stages access_group_members access_groups privacy_rules).each do |table|
      drop_table table
    end
  end

  def down
  end
end
