class AddPermissionIdToMembers < ActiveRecord::Migration
  def change
    add_column :members, :permission_id, :integer, null: false, default: 0
    add_index :members, :permission_id
    Member.all.each do |record|
      perm = record.build_permission
      perm.grantee = record.user
      perm.permissible = record.group
      perm.action = record.group.class.default_permission
      perm.save
      record.permission = perm
      record.save
    end
  end
end
