class AddDatesToThreads < ActiveRecord::Migration
  def change
    add_column :threads, :published_at, :datetime
    add_column :threads, :display_until, :datetime
  end
end
