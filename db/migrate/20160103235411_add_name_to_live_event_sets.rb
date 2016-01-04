class AddNameToLiveEventSets < ActiveRecord::Migration
  def change
    add_column :live_event_sets, :name, :string
  end
end
