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

ActiveRecord::Schema.define(:version => 20131030072542) do

  create_table "access_group_members", :force => true do |t|
    t.integer  "access_group_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "access_group_members", ["access_group_id"], :name => "index_access_group_members_on_access_group_id"
  add_index "access_group_members", ["user_id"], :name => "index_access_group_members_on_user_id"

  create_table "access_groups", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "access_groups", ["project_id"], :name => "index_access_groups_on_project_id"

  create_table "attachments", :force => true do |t|
    t.string   "file"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "caption"
    t.string   "title"
  end

  add_index "attachments", ["attachable_id", "attachable_type", "type"], :name => "index_attachments_on_attachable_id_and_attachable_type_and_type"

  create_table "broadcasts", :force => true do |t|
    t.string   "broadcastable_type", :null => false
    t.integer  "broadcastable_id",   :null => false
    t.string   "event",              :null => false
    t.integer  "context_model_id",   :null => false
    t.string   "context_model_type", :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "broadcasts", ["broadcastable_type", "broadcastable_id"], :name => "index_broadcastable"
  add_index "broadcasts", ["context_model_type", "context_model_id"], :name => "index_broadcasted"

  create_table "comments", :force => true do |t|
    t.integer  "user_id",          :null => false
    t.integer  "commentable_id",   :null => false
    t.string   "commentable_type", :null => false
    t.text     "body"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "email_threads", :force => true do |t|
    t.integer  "part_id"
    t.integer  "quantity"
    t.float    "unit_price"
    t.string   "currency"
    t.integer  "manufacturer_id"
    t.integer  "lead_time_in_days"
    t.text     "delivery_terms"
    t.text     "payment_terms"
    t.text     "custom_fields"
    t.string   "thread_hash"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "email_threads", ["manufacturer_id"], :name => "index_email_threads_on_manufacturer_id"
  add_index "email_threads", ["part_id"], :name => "index_email_threads_on_part_id"

  create_table "emails", :force => true do |t|
    t.integer  "email_thread_id"
    t.string   "from"
    t.text     "to"
    t.text     "cc"
    t.text     "body"
    t.string   "subject"
    t.text     "meta_data"
    t.integer  "sender_id"
    t.text     "raw_body"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "emails", ["email_thread_id"], :name => "index_emails_on_email_thread_id"

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "favorites", ["project_id"], :name => "index_favorites_on_project_id"
  add_index "favorites", ["user_id"], :name => "index_favorites_on_user_id"

  create_table "follow_relations", :force => true do |t|
    t.integer "follower_id", :null => false
    t.integer "followed_id", :null => false
  end

  add_index "follow_relations", ["followed_id"], :name => "index_follow_relations_on_followed_id"
  add_index "follow_relations", ["follower_id"], :name => "index_follow_relations_on_follower_id"

  create_table "friend_invites", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "impressions", :force => true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], :name => "controlleraction_ip_index"
  add_index "impressions", ["controller_name", "action_name", "request_hash"], :name => "controlleraction_request_index"
  add_index "impressions", ["controller_name", "action_name", "session_hash"], :name => "controlleraction_session_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], :name => "poly_ip_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], :name => "poly_request_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], :name => "poly_session_index"
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], :name => "impressionable_type_message_index"
  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"

  create_table "invite_codes", :force => true do |t|
    t.string   "code",       :limit => 20
    t.integer  "limit"
    t.boolean  "active",                   :default => true
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "invite_requests", :force => true do |t|
    t.string   "email"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "whitelisted"
    t.integer  "user_id",          :default => 0, :null => false
    t.string   "profile_url"
    t.string   "twitter_username"
    t.integer  "project_id"
  end

  add_index "invite_requests", ["user_id"], :name => "index_invite_requests_on_user_id"

  create_table "log_lines", :force => true do |t|
    t.string   "log_type"
    t.string   "source"
    t.text     "message"
    t.string   "loggable_type", :limit => 15
    t.integer  "loggable_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "manufacturers", :force => true do |t|
    t.string   "name"
    t.string   "email_domain"
    t.string   "website"
    t.string   "qq"
    t.string   "phone"
    t.string   "alibaba"
    t.string   "email"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "participant_invites", :force => true do |t|
    t.integer  "project_id",                    :null => false
    t.integer  "user_id"
    t.integer  "issue_id"
    t.string   "email"
    t.boolean  "accepted",   :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "participant_invites", ["accepted"], :name => "index_participant_invites_on_accepted"
  add_index "participant_invites", ["project_id"], :name => "index_participant_invites_on_project_id"

  create_table "parts", :force => true do |t|
    t.integer  "quantity"
    t.float    "unit_price"
    t.float    "total_cost"
    t.string   "name"
    t.string   "vendor_name"
    t.string   "vendor_sku"
    t.string   "vendor_link"
    t.string   "partable_type", :null => false
    t.integer  "partable_id",   :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "mpn"
    t.string   "description"
  end

  add_index "parts", ["partable_id", "partable_type"], :name => "partable_index"

  create_table "privacy_rules", :force => true do |t|
    t.boolean  "private"
    t.integer  "privatable_id"
    t.string   "privatable_type"
    t.integer  "privatable_user_id"
    t.string   "privatable_user_type"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "project_followers", :id => false, :force => true do |t|
    t.integer "user_id",    :null => false
    t.integer "project_id", :null => false
  end

  add_index "project_followers", ["project_id"], :name => "index_project_followers_on_project_id"
  add_index "project_followers", ["user_id"], :name => "index_project_followers_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "website"
    t.boolean  "private",           :default => false, :null => false
    t.string   "workflow_state"
    t.string   "one_liner"
    t.boolean  "featured"
    t.integer  "impressions_count", :default => 0
  end

  add_index "projects", ["private"], :name => "index_projects_on_private"

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

  create_table "quotes", :force => true do |t|
    t.text     "properties"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reputations", :force => true do |t|
    t.integer  "points",     :default => 0
    t.integer  "user_id",                   :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "reputations", ["user_id"], :name => "index_reputations_on_user_id"

  create_table "searches", :force => true do |t|
    t.text     "params"
    t.integer  "results"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "stages", :force => true do |t|
    t.integer  "project_id",                         :null => false
    t.string   "name"
    t.integer  "completion_rate", :default => 0
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "private",         :default => false, :null => false
    t.string   "workflow_state"
  end

  add_index "stages", ["private"], :name => "index_stages_on_private"
  add_index "stages", ["project_id"], :name => "index_stages_on_project_id"

  create_table "tags", :force => true do |t|
    t.integer  "taggable_id",   :null => false
    t.string   "taggable_type", :null => false
    t.string   "type",          :null => false
    t.string   "name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "tags", ["taggable_id", "taggable_type", "type"], :name => "index_taggable"

  create_table "team_members", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "project_id", :null => false
    t.string   "role"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "team_members", ["project_id"], :name => "index_team_members_on_project_id"
  add_index "team_members", ["user_id"], :name => "index_team_members_on_user_id"

  create_table "threads", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "threadable_id",                 :null => false
    t.string   "threadable_type",               :null => false
    t.boolean  "private"
    t.integer  "user_id",                       :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "type",            :limit => 20
    t.string   "workflow_state"
  end

  add_index "threads", ["threadable_id", "threadable_type"], :name => "index_blog_posts_on_bloggable_id_and_bloggable_type"
  add_index "threads", ["user_id"], :name => "index_blog_posts_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "user_name",              :limit => 100
    t.string   "mini_resume",            :limit => 160
    t.string   "city",                   :limit => 50
    t.string   "country",                :limit => 50
    t.integer  "roles_mask"
    t.string   "email",                                 :default => "",     :null => false
    t.string   "encrypted_password",                    :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.string   "full_name"
    t.text     "websites"
    t.integer  "categories_mask"
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "type",                                  :default => "User", :null => false
    t.integer  "invite_code_id"
    t.integer  "impressions_count",                     :default => 0
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["type"], :name => "index_users_on_type"

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.string   "link",            :limit => 100
    t.string   "provider"
    t.string   "id_for_provider"
    t.integer  "recordable_id",                                  :null => false
    t.string   "thumbnail_link"
    t.integer  "ratio_height"
    t.integer  "ratio_width"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "recordable_type",                :default => "", :null => false
  end

  add_index "videos", ["recordable_id", "recordable_type"], :name => "recordable_index"

  create_table "widgets", :force => true do |t|
    t.string   "type",                                :null => false
    t.integer  "stage_id",                            :null => false
    t.text     "properties"
    t.integer  "completion_rate",  :default => 0
    t.integer  "completion_share", :default => 0
    t.string   "name"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "private",          :default => false, :null => false
    t.integer  "project_id",       :default => 0,     :null => false
    t.string   "position",         :default => "",    :null => false
  end

  add_index "widgets", ["position"], :name => "index_widgets_on_position"
  add_index "widgets", ["private"], :name => "index_widgets_on_private"
  add_index "widgets", ["project_id"], :name => "index_widgets_on_project_id"
  add_index "widgets", ["stage_id"], :name => "index_widgets_on_stage_id"

end
