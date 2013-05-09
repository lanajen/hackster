class CreateLogLines < ActiveRecord::Migration
  def change
    create_table "log_lines" do |t|
      t.string   "log_type"
      t.string   "source"
      t.text     "message"
      t.string   "loggable_type", :limit => 15
      t.integer  "loggable_id"
      t.datetime "created_at",                  :null => false
      t.datetime "updated_at",                  :null => false
    end
  end
end
