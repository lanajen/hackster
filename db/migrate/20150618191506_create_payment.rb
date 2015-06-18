class CreatePayment < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :recipient_name
      t.string :invoice_number
      t.string :recipient_email
      t.integer :amount
      t.string :workflow_state
      t.hstore :properties
      t.string :safe_id, null: false

      t.timestamps null: false
    end
    add_index :payments, :safe_id, unique: true
    add_index :payments, :workflow_state
  end
end
