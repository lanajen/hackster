class CreatePrivacyRules < ActiveRecord::Migration
  def change
    create_table :privacy_rules do |t|
      t.boolean :private
      t.integer :privatable_id
      t.string :privatable_type
      t.integer :privatable_user_id
      t.string :privatable_user_type

      t.timestamps
    end
  end
end
