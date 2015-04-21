class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :notifiable_type
      t.integer :notifiable_id
      t.string :event
      # t.integer :user_id

      t.timestamps null: false
    end
  end
end
