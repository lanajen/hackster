class AddHpropertiesToThreads < ActiveRecord::Migration
  def change
    add_column :threads, :hproperties, :hstore
  end
end
