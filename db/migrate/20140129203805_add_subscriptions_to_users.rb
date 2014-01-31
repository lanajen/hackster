class AddSubscriptionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscriptions_mask, :integer, default: 0
    add_column :users, :mailchimp_registered, :boolean, default: false
  end
end

# User.where.not(user_name: nil).each{|u| u.subscriptions=User::SUBSCRIPTIONS.keys;u.save}