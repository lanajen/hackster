# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130320230202) do

  create_table "attachments", :force => true do |t|
    t.string   "file"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "attachments", ["attachable_id", "attachable_type", "type"], :name => "index_attachments_on_attachable_id_and_attachable_type_and_type"

  create_table "follow_relations", :force => true do |t|
    t.integer "follower_id", :null => false
    t.integer "followed_id", :null => false
  end

  add_index "follow_relations", ["followed_id"], :name => "index_follow_relations_on_followed_id"
  add_index "follow_relations", ["follower_id"], :name => "index_follow_relations_on_follower_id"

  create_table "invite_requests", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "project_followers", :id => false, :force => true do |t|
    t.integer "user_id",    :null => false
    t.integer "project_id", :null => false
  end

  add_index "project_followers", ["project_id"], :name => "index_project_followers_on_project_id"
  add_index "project_followers", ["user_id"], :name => "index_project_followers_on_user_id"

  create_table "projects", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "name"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "projects", ["user_id"], :name => "index_projects_on_user_id"

  create_table "publications", :force => true do |t|
    t.string   "title"
    t.text     "abstract"
    t.string   "coauthors"
    t.date     "published_on"
    t.string   "journal"
    t.string   "link"
    t.integer  "user_id",      :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "publications", ["user_id"], :name => "index_publications_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "user_name",              :limit => 100
    t.string   "mini_resume",            :limit => 160
    t.string   "city",                   :limit => 50
    t.string   "country",                :limit => 50
    t.integer  "roles_mask"
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",                    :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "name"
    t.text     "websites"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "videos", :force => true do |t|
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
