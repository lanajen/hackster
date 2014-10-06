class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.integer :duration
      t.text :properties
      t.datetime :start_date
      t.string :video_link
      t.text :counters_cache
      t.integer :tech_id
      t.string :name
      t.string :slug
      t.string :workflow_state

      t.timestamps
    end

    create_table :challenge_projects do |t|
      t.integer :project_id
      t.integer :challenge_id
      t.string :workflow_state
      t.text :submission_notes
      t.text :judging_notes
      t.integer :prize_id

      t.timestamps
    end

    create_table :prizes do |t|
      t.integer :challenge_id
      t.string :name
      t.text :description
      t.integer :position
      t.boolean :requires_shipping
    end

    create_table :addresses do |t|
      t.integer :addressable_id
      t.string :addressable_type
      t.string :full_name
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :country
      t.string :zip
      t.string :phone
    end

    create_table :challenge_admins do |t|
      t.integer :challenge_id
      t.integer :user_id
      t.integer :roles_mask
    end
  end
end
