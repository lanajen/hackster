class DeleteLiveChapters < ActiveRecord::Migration
  def up
    drop_table :live_chapters
  end

  def down
  end
end
