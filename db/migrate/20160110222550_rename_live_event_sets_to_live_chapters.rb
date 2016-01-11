class RenameLiveEventSetsToLiveChapters < ActiveRecord::Migration
  def change
    rename_table :live_event_sets, :live_chapters
  end
end
