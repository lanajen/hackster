class CreateLiveEventSets < ActiveRecord::Migration
  def change
    create_table :live_event_sets do |t|
      t.string :event_type
      t.string :link
      t.integer :organizer_id, null: false
      t.string :city
      t.string :country
      t.boolean :virtual, default: false

      t.timestamps null: false
    end
    add_index :live_event_sets, :organizer_id
  end
end
