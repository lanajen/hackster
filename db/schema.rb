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
# It's strongly recommended that you check this file into your version control system.

<<<<<<< HEAD
ActiveRecord::Schema.define(version: 20140311013224) do
=======
ActiveRecord::Schema.define(version: 20140311203251) do
>>>>>>> master

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignee_issues", force: true do |t|
    t.integer  "assignee_id", null: false
    t.integer  "issue_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignee_issues", ["assignee_id"], name: "index_assignee_issues_on_assignee_id", using: :btree
  add_index "assignee_issues", ["issue_id"], name: "index_assignee_issues_on_issue_id", using: :btree

  create_table "assignments", force: true do |t|
    t.integer  "promotion_id",                     null: false
    t.integer  "id_for_promotion",                 null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "grading_type"
    t.boolean  "graded",           default: false
    t.boolean  "private_grades",   default: true
  end

  add_index "assignments", ["id_for_promotion"], name: "index_assignments_on_id_for_promotion", using: :btree
  add_index "assignments", ["promotion_id"], name: "index_assignments_on_promotion_id", using: :btree

  create_table "attachments", force: true do |t|
    t.string   "file"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "caption"
    t.string   "title"
    t.integer  "position"
    t.string   "tmp_file"
  end

  add_index "attachments", ["attachable_id", "attachable_type", "type"], name: "index_attachments_on_attachable_id_and_attachable_type_and_type", using: :btree

  create_table "authorizations", force: true do |t|
    t.string   "uid",        limit: 100, null: false
    t.string   "provider",   limit: 50,  null: false
    t.integer  "user_id",                null: false
    t.string   "name"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "secret"
  end

  add_index "authorizations", ["provider", "uid"], name: "index_authorizations_on_provider_and_uid", using: :btree
  add_index "authorizations", ["user_id"], name: "index_authorizations_on_user_id", using: :btree

  create_table "broadcasts", force: true do |t|
    t.string   "broadcastable_type", null: false
    t.integer  "broadcastable_id",   null: false
    t.string   "event",              null: false
    t.integer  "context_model_id",   null: false
    t.string   "context_model_type", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
    t.integer  "project_id"
  end

  add_index "broadcasts", ["broadcastable_type", "broadcastable_id"], name: "index_broadcastable", using: :btree
  add_index "broadcasts", ["context_model_type", "context_model_id"], name: "index_broadcasted", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "user_id",          default: 0, null: false
    t.integer  "commentable_id",               null: false
    t.string   "commentable_type",             null: false
    t.text     "body"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "parent_id"
    t.string   "guest_name"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "courses_universities", force: true do |t|
    t.integer "university_id"
    t.integer "course_id"
  end

  create_table "favorites", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "favorites", ["project_id"], name: "index_favorites_on_project_id", using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

  create_table "follow_relations", force: true do |t|
    t.integer  "user_id"
    t.integer  "followable_id"
    t.string   "followable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follow_relations", ["followable_id", "followable_type"], name: "index_follow_relations_on_followable_id_and_followable_type", using: :btree
  add_index "follow_relations", ["user_id"], name: "index_follow_relations_on_user_id", using: :btree

  create_table "friend_invites", force: true do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grades", force: true do |t|
    t.integer  "gradable_id",             null: false
    t.string   "gradable_type",           null: false
    t.string   "grade",         limit: 3
    t.text     "feedback"
    t.integer  "project_id",              null: false
    t.integer  "user_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grades", ["gradable_type", "gradable_id"], name: "index_grades_on_gradable_type_and_gradable_id", using: :btree
  add_index "grades", ["project_id"], name: "index_grades_on_project_id", using: :btree
  add_index "grades", ["user_id"], name: "index_grades_on_user_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "user_name",         limit: 100
    t.string   "city",              limit: 50
    t.string   "country",           limit: 50
    t.string   "mini_resume",       limit: 160
    t.string   "full_name"
    t.string   "email"
    t.text     "websites"
    t.string   "type",              limit: 15,  default: "Group", null: false
    t.integer  "impressions_count",             default: 0
    t.text     "counters_cache"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",                       default: false
    t.integer  "parent_id"
    t.string   "access_level"
    t.string   "invitation_token",  limit: 30
  end

  add_index "groups", ["type"], name: "index_groups_on_type", using: :btree

  create_table "impressions", force: true do |t|
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
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "invite_codes", force: true do |t|
    t.string   "code",       limit: 20
    t.integer  "limit"
    t.boolean  "active",                default: true
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "invite_requests", force: true do |t|
    t.string   "email"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.boolean  "whitelisted"
    t.integer  "user_id",     default: 0, null: false
    t.integer  "project_id"
  end

  add_index "invite_requests", ["user_id"], name: "index_invite_requests_on_user_id", using: :btree

  create_table "log_lines", force: true do |t|
    t.string   "log_type"
    t.string   "source"
    t.text     "message"
    t.string   "loggable_type", limit: 15
    t.integer  "loggable_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "members", force: true do |t|
    t.integer  "group_id",                           null: false
    t.integer  "user_id",                            null: false
    t.string   "title"
    t.integer  "group_roles_mask"
    t.string   "mini_resume"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_sent_at"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "permission_id",          default: 0, null: false
  end

  add_index "members", ["group_id"], name: "index_members_on_group_id", using: :btree
  add_index "members", ["permission_id"], name: "index_members_on_permission_id", using: :btree
  add_index "members", ["user_id"], name: "index_members_on_user_id", using: :btree

  create_table "parts", force: true do |t|
    t.integer  "quantity",      default: 1
    t.float    "unit_price",    default: 0.0
    t.float    "total_cost",    default: 0.0
    t.string   "name"
    t.string   "vendor_name"
    t.string   "vendor_sku"
    t.string   "vendor_link"
    t.string   "partable_type",               null: false
    t.integer  "partable_id",                 null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "mpn"
    t.string   "description"
    t.integer  "position"
  end

  add_index "parts", ["partable_id", "partable_type"], name: "partable_index", using: :btree

  create_table "permissions", force: true do |t|
    t.string   "permissible_type", limit: 15, null: false
    t.integer  "permissible_id",              null: false
    t.string   "action",           limit: 20
    t.string   "grantee_type",     limit: 15, null: false
    t.integer  "grantee_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["grantee_type", "grantee_id"], name: "index_permissions_on_grantee_type_and_grantee_id", using: :btree
  add_index "permissions", ["permissible_id", "permissible_type"], name: "index_permissions_on_permissible_id_and_permissible_type", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "website"
    t.boolean  "private",                        default: false, null: false
    t.string   "workflow_state"
    t.string   "one_liner"
    t.boolean  "featured"
    t.integer  "impressions_count",              default: 0
    t.text     "counters_cache"
    t.integer  "team_id",                        default: 0,     null: false
    t.string   "license",            limit: 50
    t.string   "slug",               limit: 105
    t.datetime "featured_date"
    t.datetime "made_public_at"
    t.boolean  "hide",                           default: false
    t.integer  "assignment_id"
<<<<<<< HEAD
    t.boolean  "graded",                        default: false
    t.boolean  "wip",                           default: false
=======
    t.boolean  "graded",                         default: false
    t.boolean  "wip",                            default: false
    t.integer  "popularity_counter",             default: 0
>>>>>>> master
  end

  add_index "projects", ["private"], name: "index_projects_on_private", using: :btree
  add_index "projects", ["team_id"], name: "index_projects_on_team_id", using: :btree

  create_table "reputations", force: true do |t|
    t.integer  "points",     default: 0
    t.integer  "user_id",                null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "reputations", ["user_id"], name: "index_reputations_on_user_id", using: :btree

  create_table "slug_histories", force: true do |t|
    t.string   "value",      null: false
    t.integer  "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "slug_histories", ["project_id"], name: "index_slug_histories_on_project_id", using: :btree
  add_index "slug_histories", ["value"], name: "index_slug_histories_on_value", using: :btree

  create_table "subdomains", force: true do |t|
    t.string   "subdomain"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.integer  "taggable_id",   null: false
    t.string   "taggable_type", null: false
    t.string   "type",          null: false
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "tags", ["taggable_id", "taggable_type", "type"], name: "index_taggable", using: :btree

  create_table "team_members", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "project_id", null: false
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "team_members", ["project_id"], name: "index_team_members_on_project_id", using: :btree
  add_index "team_members", ["user_id"], name: "index_team_members_on_user_id", using: :btree

  create_table "threads", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "threadable_id",                          null: false
    t.string   "threadable_type",                        null: false
    t.boolean  "private"
    t.integer  "user_id",                                null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "type",            limit: 20
    t.string   "workflow_state"
    t.integer  "sub_id",                     default: 0, null: false
  end

  add_index "threads", ["sub_id", "threadable_id", "threadable_type"], name: "threadable_sub_ids", using: :btree
  add_index "threads", ["threadable_id", "threadable_type"], name: "index_blog_posts_on_bloggable_id_and_bloggable_type", using: :btree
  add_index "threads", ["user_id"], name: "index_blog_posts_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "user_name",              limit: 100
    t.string   "mini_resume",            limit: 160
    t.string   "city",                   limit: 50
    t.string   "country",                limit: 50
    t.integer  "roles_mask"
    t.string   "email",                              default: "",     null: false
    t.string   "encrypted_password",                 default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "full_name"
    t.text     "websites"
    t.integer  "categories_mask"
    t.string   "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "type",                               default: "User", null: false
    t.integer  "invite_code_id"
    t.integer  "impressions_count",                  default: 0
    t.text     "counters_cache"
    t.text     "notifications"
    t.datetime "invitation_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "subscriptions_mask",                 default: 0
    t.boolean  "mailchimp_registered",               default: false
    t.string   "authentication_token",   limit: 25
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["type"], name: "index_users_on_type", using: :btree

  create_table "videos", force: true do |t|
    t.string   "title"
    t.string   "link"
    t.string   "provider"
    t.string   "id_for_provider"
    t.integer  "recordable_id",                null: false
    t.string   "thumbnail_link"
    t.integer  "ratio_height"
    t.integer  "ratio_width"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "recordable_type", default: "", null: false
  end

  add_index "videos", ["recordable_id", "recordable_type"], name: "recordable_index", using: :btree

  create_table "widgets", force: true do |t|
    t.string   "type",                    null: false
    t.text     "properties"
    t.string   "name"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "project_id", default: 0,  null: false
    t.string   "position",   default: "", null: false
  end

  add_index "widgets", ["position"], name: "index_widgets_on_position", using: :btree
  add_index "widgets", ["project_id"], name: "index_widgets_on_project_id", using: :btree

end
