class AddOneLinerToLiveChapters < ActiveRecord::Migration
  def change
    add_column :live_chapters, :one_liner, :string, limit: 160
  end
end
