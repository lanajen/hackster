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