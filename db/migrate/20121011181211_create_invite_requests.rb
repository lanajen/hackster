class CreateInviteRequests < ActiveRecord::Migration
  def change
    create_table :invite_requests do |t|
      t.string :email

      t.timestamps
    end
  end
end
