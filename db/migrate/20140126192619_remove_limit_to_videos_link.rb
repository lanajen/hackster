class RemoveLimitToVideosLink < ActiveRecord::Migration
  def change
    change_column :videos, :link, :string, limit: nil
  end
end
