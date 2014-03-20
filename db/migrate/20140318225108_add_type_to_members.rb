class AddTypeToMembers < ActiveRecord::Migration
  def change
    add_column :members, :type, :string, null: false, default: 'Member'
    Member.update_all(type: 'PromotionMember')
  end
end
