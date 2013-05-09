class CreateParticipantInvites < ActiveRecord::Migration
  def change
    create_table :participant_invites do |t|
      t.integer :project_id, null: false
      t.integer :user_id
      t.integer :issue_id
      t.string :email
      t.boolean :accepted, null: false, default: false

      t.timestamps
    end
    add_index :participant_invites, :project_id
    add_index :participant_invites, :accepted
  end
end
