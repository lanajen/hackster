class AddSubscriptionsMasksToUsers < ActiveRecord::Migration
  def up
    enable_extension :hstore
    add_column :users, :subscriptions_masks, :hstore, null: false, default: ''
  end

  def down
    remove_column :users, :subscriptions_masks
    disable_extension :hstore
  end
end

# User.update_all("subscriptions_masks = subscriptions_masks || hstore('email', subscriptions_mask::varchar)")
# User.update_all([%(subscriptions_masks = subscriptions_masks || hstore(?,?)), 'web', User::SUBSCRIPTIONS[:web].keys.map{ |r| 2**User::SUBSCRIPTIONS[:web].keys.index(r) }.sum.to_s])
# User.user_name_set.invitation_accepted_or_not_invited.update_all([%(subscriptions_masks = subscriptions_masks || hstore('email',CAST(CAST(subscriptions_masks -> 'email' AS INTEGER) + #{%w(new_comment_update new_comment_update_commented new_like new_mention).map{|key| 2**User::SUBSCRIPTIONS[:email].keys.index(key) }.sum} AS TEXT)))])