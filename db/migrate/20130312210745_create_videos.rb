class CreateVideos < ActiveRecord::Migration
  def change
    create_table "videos" do |t|
      t.string   "title"
      t.string   "link",            :limit => 100
      t.string   "provider"
      t.string   "id_for_provider"
      t.integer  "project_id",                     :null => false
      t.string   "thumbnail_link"
      t.integer  "ratio_height"
      t.integer  "ratio_width"
      t.datetime "created_at",                     :null => false
      t.datetime "updated_at",                     :null => false
    end

    add_index "videos", ["project_id"], :name => "index_videos_on_project_id"
  end
end
