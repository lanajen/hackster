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

ActiveRecord::Schema.define(version: 20160603222251) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_stat_statements"

  create_table "addresses", force: :cascade do |t|
    t.integer "addressable_id"
    t.string  "addressable_type", limit: 255
    t.string  "full_name",        limit: 255
    t.string  "address_line1",    limit: 255
    t.string  "address_line2",    limit: 255
    t.string  "city",             limit: 255
    t.string  "state",            limit: 255
    t.string  "country",          limit: 255
    t.string  "zip",              limit: 255
    t.string  "phone",            limit: 255
    t.boolean "default",                      default: false
    t.boolean "deleted",                      default: false
  end

  create_table "assignee_issues", force: :cascade do |t|
    t.integer  "assignee_id", null: false
    t.integer  "issue_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignee_issues", ["assignee_id"], name: "index_assignee_issues_on_assignee_id", using: :btree
  add_index "assignee_issues", ["issue_id"], name: "index_assignee_issues_on_issue_id", using: :btree

  create_table "assignments", force: :cascade do |t|
    t.integer  "promotion_id",                                 null: false
    t.integer  "id_for_promotion",                             null: false
    t.string   "name",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "grading_type",     limit: 255
    t.boolean  "graded",                       default: false
    t.boolean  "private_grades",               default: true
    t.text     "properties"
    t.datetime "submit_by_date"
    t.datetime "reminder_sent_at"
  end

  add_index "assignments", ["id_for_promotion"], name: "index_assignments_on_id_for_promotion", using: :btree
  add_index "assignments", ["promotion_id"], name: "index_assignments_on_promotion_id", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "file",            limit: 255
    t.integer  "attachable_id"
    t.string   "attachable_type", limit: 255
    t.string   "type",            limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.text     "caption"
    t.string   "title",           limit: 255
    t.integer  "position"
    t.text     "tmp_file"
    t.boolean  "use_alt",                     default: false
  end

  add_index "attachments", ["attachable_id", "attachable_type", "type"], name: "index_attachments_on_attachable_id_and_attachable_type_and_type", using: :btree

  create_table "authorizations", force: :cascade do |t|
    t.string   "uid",        limit: 100, null: false
    t.string   "provider",   limit: 50,  null: false
    t.integer  "user_id",                null: false
    t.string   "name",       limit: 255
    t.string   "link",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "token"
    t.text     "secret"
  end

  add_index "authorizations", ["provider", "uid"], name: "index_authorizations_on_provider_and_uid", using: :btree
  add_index "authorizations", ["user_id"], name: "index_authorizations_on_user_id", using: :btree

  create_table "awarded_badges", force: :cascade do |t|
    t.integer  "awardee_id"
    t.string   "awardee_type", limit: 255
    t.string   "badge_code",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "level",        limit: 255
  end

  add_index "awarded_badges", ["awardee_id", "awardee_type", "badge_code"], name: "awarded_badges_awardee_badge_index", unique: true, using: :btree

  create_table "challenge_admins", force: :cascade do |t|
    t.integer "challenge_id"
    t.integer "user_id"
    t.integer "roles_mask"
  end

  create_table "challenge_categories", force: :cascade do |t|
    t.integer "challenge_id", null: false
    t.string  "name"
  end

  add_index "challenge_categories", ["challenge_id"], name: "index_challenge_categories_on_challenge_id", using: :btree

  create_table "challenge_ideas", force: :cascade do |t|
    t.integer  "challenge_id"
    t.integer  "user_id"
    t.string   "name"
    t.hstore   "properties"
    t.string   "workflow_state"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "address_id"
  end

  create_table "challenge_projects", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "challenge_id"
    t.string   "workflow_state",   limit: 255
    t.text     "submission_notes"
    t.text     "judging_notes"
    t.integer  "prize_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.hstore   "counters_cache"
    t.integer  "category_id"
    t.hstore   "properties"
  end

  create_table "challenge_projects_prizes", force: :cascade do |t|
    t.integer "challenge_entry_id"
    t.integer "prize_id"
  end

  create_table "challenge_registrations", force: :cascade do |t|
    t.integer  "user_id",      null: false
    t.integer  "challenge_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.hstore   "hproperties"
  end

  add_index "challenge_registrations", ["challenge_id"], name: "index_challenge_registrations_on_challenge_id", using: :btree
  add_index "challenge_registrations", ["user_id"], name: "index_challenge_registrations_on_user_id", using: :btree

  create_table "challenges", force: :cascade do |t|
    t.integer  "duration"
    t.text     "properties"
    t.datetime "start_date"
    t.string   "video_link",        limit: 255
    t.text     "counters_cache"
    t.integer  "platform_id"
    t.string   "name",              limit: 255
    t.string   "slug",              limit: 255
    t.string   "workflow_state",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "end_date"
    t.integer  "impressions_count"
    t.hstore   "hproperties"
    t.hstore   "hcounters_cache"
  end

  create_table "challenges_groups", id: false, force: :cascade do |t|
    t.integer "group_id",     null: false
    t.integer "challenge_id", null: false
  end

  add_index "challenges_groups", ["challenge_id"], name: "index_challenges_groups_on_challenge_id", using: :btree
  add_index "challenges_groups", ["group_id"], name: "index_challenges_groups_on_group_id", using: :btree

  create_table "channels", force: :cascade do |t|
    t.string   "name"
    t.integer  "group_id"
    t.text     "cache_counters"
    t.boolean  "restricted"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "channels_hashtags", force: :cascade do |t|
    t.integer "hashtag_id"
    t.integer "channel_id"
  end

  add_index "channels_hashtags", ["channel_id"], name: "index_channels_hashtags_on_channel_id", using: :btree
  add_index "channels_hashtags", ["hashtag_id"], name: "index_channels_hashtags_on_hashtag_id", using: :btree

  create_table "chat_messages", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.text     "body"
    t.integer  "group_id",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_name",  limit: 255
    t.string   "source",     limit: 255
    t.text     "raw_body"
  end

  add_index "chat_messages", ["group_id"], name: "index_chat_messages_on_group_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",                      default: 0,     null: false
    t.integer  "commentable_id",                               null: false
    t.string   "commentable_type", limit: 255,                 null: false
    t.text     "body"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "parent_id"
    t.string   "guest_name",       limit: 255
    t.text     "raw_body"
    t.boolean  "deleted",                      default: false
    t.string   "hid",              limit: 16
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["deleted"], name: "index_comments_on_deleted", using: :btree
  add_index "comments", ["hid"], name: "index_comments_on_hid", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.string   "subject",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses_universities", force: :cascade do |t|
    t.integer "university_id"
    t.integer "course_id"
  end

  create_table "follow_relations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "followable_id"
    t.string   "followable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follow_relations", ["followable_id", "followable_type"], name: "index_follow_relations_on_followable_id_and_followable_type", using: :btree
  add_index "follow_relations", ["user_id"], name: "index_follow_relations_on_user_id", using: :btree

  create_table "friend_invites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grades", force: :cascade do |t|
    t.integer  "gradable_id",                                 null: false
    t.string   "gradable_type", limit: 255,                   null: false
    t.string   "grade",         limit: 255
    t.text     "feedback"
    t.integer  "project_id",                                  null: false
    t.integer  "user_id",                                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",          limit: 20,  default: "Grade", null: false
  end

  add_index "grades", ["gradable_type", "gradable_id"], name: "index_grades_on_gradable_type_and_gradable_id", using: :btree
  add_index "grades", ["project_id"], name: "index_grades_on_project_id", using: :btree
  add_index "grades", ["type"], name: "index_grades_on_type", using: :btree
  add_index "grades", ["user_id"], name: "index_grades_on_user_id", using: :btree

  create_table "group_impressions", force: :cascade do |t|
    t.integer  "group_id",     null: false
    t.string   "session_hash"
    t.text     "message"
    t.datetime "created_at",   null: false
  end

  add_index "group_impressions", ["created_at"], name: "group_impressions_created_at_idx", using: :btree
  add_index "group_impressions", ["group_id"], name: "index_group_impressions_on_group_id", using: :btree
  add_index "group_impressions", ["session_hash"], name: "index_group_impressions_on_session_hash", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "user_name",         limit: 100
    t.string   "city",              limit: 50
    t.string   "country",           limit: 50
    t.string   "mini_resume",       limit: 160
    t.string   "full_name",         limit: 255
    t.string   "email",             limit: 255
    t.text     "websites"
    t.string   "type",              limit: 15,  default: "Group", null: false
    t.integer  "impressions_count",             default: 0
    t.text     "counters_cache"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",                       default: false
    t.integer  "parent_id"
    t.string   "access_level",      limit: 255
    t.string   "invitation_token",  limit: 30
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address",           limit: 255
    t.string   "state",             limit: 255
    t.text     "properties"
    t.integer  "projects_count"
    t.integer  "members_count"
    t.string   "zipcode",           limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.hstore   "hproperties"
    t.hstore   "hcounters_cache"
    t.boolean  "virtual",                       default: false
  end

  add_index "groups", ["type"], name: "index_groups_on_type", using: :btree

  create_table "hashtags", force: :cascade do |t|
    t.string   "name"
    t.text     "cache_counters"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "hashtags_thoughts", force: :cascade do |t|
    t.integer "hashtag_id"
    t.integer "thought_id"
  end

  add_index "hashtags_thoughts", ["hashtag_id"], name: "index_hashtags_thoughts_on_hashtag_id", using: :btree
  add_index "hashtags_thoughts", ["thought_id"], name: "index_hashtags_thoughts_on_thought_id", using: :btree

  create_table "impressions", force: :cascade do |t|
    t.string   "impressionable_type",             null: false
    t.integer  "impressionable_id",               null: false
    t.string   "session_hash",        limit: 255
    t.text     "message"
    t.datetime "created_at",                      null: false
  end

  add_index "impressions", ["created_at"], name: "impressions_created_at_idx", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.string   "url"
    t.string   "title"
    t.string   "employer_name"
    t.string   "location"
    t.integer  "platform_id"
    t.string   "workflow_state"
    t.integer  "clicks_count",   default: 0
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "jobs", ["platform_id"], name: "index_jobs_on_platform_id", using: :btree

  create_table "link_data", force: :cascade do |t|
    t.string   "title"
    t.string   "website_name"
    t.text     "description"
    t.string   "extra_data_value1"
    t.string   "extra_data_value2"
    t.string   "extra_data_label1"
    t.string   "extra_data_label2"
    t.string   "link",              null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "link_data", ["link"], name: "index_link_data_on_link", using: :btree

  create_table "log_lines", force: :cascade do |t|
    t.string   "log_type",      limit: 255
    t.string   "source",        limit: 255
    t.text     "message"
    t.string   "loggable_type", limit: 15
    t.integer  "loggable_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "members", force: :cascade do |t|
    t.integer  "group_id",                                              null: false
    t.integer  "user_id",                                               null: false
    t.string   "title",                  limit: 255
    t.integer  "group_roles_mask"
    t.string   "mini_resume",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_sent_at"
    t.integer  "invited_by_id"
    t.string   "invited_by_type",        limit: 255
    t.integer  "permission_id",                      default: 0,        null: false
    t.string   "type",                   limit: 255, default: "Member", null: false
    t.datetime "requested_to_join_at"
    t.boolean  "approved_to_join"
  end

  add_index "members", ["group_id"], name: "index_members_on_group_id", using: :btree
  add_index "members", ["permission_id"], name: "index_members_on_permission_id", using: :btree
  add_index "members", ["user_id"], name: "index_members_on_user_id", using: :btree

  create_table "monologue_tags", force: :cascade do |t|
    t.string "name", limit: 255
  end

  add_index "monologue_tags", ["name"], name: "index_monologue_tags_on_name", using: :btree

  create_table "mouser_submissions", force: :cascade do |t|
    t.string   "status"
    t.string   "project_name"
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "vendor_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "notifiable_type"
    t.integer  "notifiable_id"
    t.string   "event"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                         null: false
    t.string   "uid",                          null: false
    t.string   "secret",                       null: false
    t.text     "redirect_uri",                 null: false
    t.string   "scopes",       default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.boolean  "trusted_app",  default: false
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "order_lines", force: :cascade do |t|
    t.integer "store_product_id", null: false
    t.integer "order_id",         null: false
  end

  add_index "order_lines", ["order_id"], name: "index_order_lines_on_order_id", using: :btree
  add_index "order_lines", ["store_product_id"], name: "index_order_lines_on_store_product_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "total_cost"
    t.integer  "products_cost"
    t.integer  "shipping_cost"
    t.integer  "address_id"
    t.string   "workflow_state"
    t.string   "tracking_number"
    t.integer  "user_id",                   null: false
    t.hstore   "counters_cache"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.datetime "placed_at"
    t.datetime "shipped_at"
    t.float    "shipping_cost_in_currency"
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "part_impressions", force: :cascade do |t|
    t.integer  "part_id",      null: false
    t.string   "session_hash"
    t.text     "message"
    t.datetime "created_at",   null: false
  end

  add_index "part_impressions", ["created_at"], name: "part_impressions_created_at_idx", using: :btree
  add_index "part_impressions", ["part_id"], name: "index_part_impressions_on_part_id", using: :btree
  add_index "part_impressions", ["session_hash"], name: "index_part_impressions_on_session_hash", using: :btree

  create_table "part_joins", force: :cascade do |t|
    t.integer  "part_id",                                       null: false
    t.integer  "partable_id",                                   null: false
    t.string   "partable_type",         limit: 255,             null: false
    t.integer  "quantity",                          default: 1
    t.string   "unquantifiable_amount", limit: 255
    t.float    "total_cost"
    t.text     "comment"
    t.integer  "position",                          default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "part_joins", ["part_id"], name: "index_part_joins_on_part_id", using: :btree
  add_index "part_joins", ["partable_id", "partable_type", "position"], name: "index_part_joins_on_partable_id_and_partable_type_and_position", using: :btree

  create_table "part_relations", force: :cascade do |t|
    t.integer "parent_part_id"
    t.integer "child_part_id"
  end

  add_index "part_relations", ["child_part_id"], name: "index_part_relations_on_child_part_id", using: :btree
  add_index "part_relations", ["parent_part_id"], name: "index_part_relations_on_parent_part_id", using: :btree

  create_table "parts", force: :cascade do |t|
    t.integer  "quantity",                          default: 1
    t.float    "unit_price",                        default: 0.0
    t.float    "total_cost",                        default: 0.0
    t.string   "name",                  limit: 255
    t.string   "vendor_name",           limit: 255
    t.string   "vendor_sku",            limit: 255
    t.string   "vendor_link",           limit: 255
    t.string   "partable_type",         limit: 255,                          null: false
    t.integer  "partable_id",                                                null: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "mpn",                   limit: 255
    t.text     "description"
    t.integer  "position"
    t.string   "comment",               limit: 255
    t.text     "websites"
    t.integer  "platform_id"
    t.boolean  "private",                           default: false
    t.string   "product_tags_string",   limit: 255
    t.string   "workflow_state",        limit: 255
    t.string   "slug",                  limit: 255
    t.string   "one_liner",             limit: 140
    t.hstore   "counters_cache"
    t.string   "type",                  limit: 15,  default: "HardwarePart"
    t.boolean  "generic"
    t.integer  "impressions_count",                 default: 0
    t.boolean  "exclude_from_platform",             default: false
  end

  add_index "parts", ["exclude_from_platform"], name: "index_parts_on_exclude_from_platform", using: :btree
  add_index "parts", ["partable_id", "partable_type"], name: "partable_index", using: :btree
  add_index "parts", ["platform_id"], name: "index_parts_on_platform_id", using: :btree

  create_table "parts_platforms", force: :cascade do |t|
    t.integer "part_id",     null: false
    t.integer "platform_id", null: false
  end

  add_index "parts_platforms", ["part_id"], name: "index_parts_platforms_on_part_id", using: :btree
  add_index "parts_platforms", ["platform_id"], name: "index_parts_platforms_on_platform_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.string   "recipient_name"
    t.string   "invoice_number"
    t.string   "recipient_email"
    t.float    "amount"
    t.string   "workflow_state"
    t.hstore   "properties"
    t.string   "safe_id",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "payable_id"
    t.string   "payable_type"
    t.string   "stripe_token"
  end

  add_index "payments", ["safe_id"], name: "index_payments_on_safe_id", unique: true, using: :btree
  add_index "payments", ["workflow_state"], name: "index_payments_on_workflow_state", using: :btree

  create_table "permissions", force: :cascade do |t|
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

  create_table "prizes", force: :cascade do |t|
    t.integer "challenge_id"
    t.string  "name",              limit: 255
    t.text    "description"
    t.integer "position"
    t.boolean "requires_shipping"
    t.integer "quantity",                      default: 1
    t.integer "cash_value"
    t.string  "link",              limit: 255
  end

  create_table "project_collections", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "collectable_id"
    t.string   "collectable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "workflow_state",   limit: 255
    t.text     "comment"
    t.hstore   "properties"
  end

  create_table "project_impressions", force: :cascade do |t|
    t.integer  "project_id",   null: false
    t.string   "session_hash"
    t.text     "message"
    t.datetime "created_at",   null: false
  end

  add_index "project_impressions", ["created_at"], name: "project_impressions_created_at_idx", using: :btree
  add_index "project_impressions", ["project_id"], name: "index_project_impressions_on_project_id", using: :btree
  add_index "project_impressions", ["session_hash"], name: "index_project_impressions_on_session_hash", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.text     "description"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "website",                 limit: 255
    t.boolean  "private",                             default: false,     null: false
    t.string   "workflow_state",          limit: 255
    t.string   "one_liner",               limit: 255
    t.boolean  "featured"
    t.integer  "impressions_count",                   default: 0
    t.text     "counters_cache"
    t.integer  "team_id",                             default: 0,         null: false
    t.string   "license",                 limit: 100
    t.string   "slug",                    limit: 105
    t.datetime "featured_date"
    t.datetime "made_public_at"
    t.boolean  "hide",                                default: false
    t.boolean  "graded",                              default: false
    t.float    "popularity_counter",                  default: 0.0
    t.integer  "respects_count",                      default: 0
    t.string   "guest_name",              limit: 128
    t.boolean  "approved"
    t.datetime "last_edited_at"
    t.text     "properties"
    t.string   "platform_tags_string",    limit: 255
    t.text     "product_tags_string"
    t.datetime "assignment_submitted_at"
    t.string   "difficulty",              limit: 255
    t.string   "type",                    limit: 15,  default: "Project", null: false
    t.string   "locale",                  limit: 2,   default: "en"
    t.string   "hid"
    t.hstore   "hproperties"
    t.integer  "origin_platform_id",                  default: 0,         null: false
  end

  add_index "projects", ["hid"], name: "index_projects_on_hid", using: :btree
  add_index "projects", ["locale"], name: "index_projects_on_locale", using: :btree
  add_index "projects", ["origin_platform_id"], name: "index_projects_on_origin_platform_id", using: :btree
  add_index "projects", ["private"], name: "index_projects_on_private", using: :btree
  add_index "projects", ["team_id"], name: "index_projects_on_team_id", using: :btree
  add_index "projects", ["type"], name: "index_projects_on_type", using: :btree

  create_table "receipts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "receivable_id"
    t.integer  "conversation_id"
    t.boolean  "read",            default: false
    t.boolean  "deleted",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "receivable_type", default: "Comment", null: false
  end

  add_index "receipts", ["conversation_id"], name: "index_receipts_on_conversation_id", using: :btree
  add_index "receipts", ["receivable_id", "receivable_type"], name: "index_receipts_on_receivable_id_and_receivable_type", using: :btree
  add_index "receipts", ["user_id"], name: "index_receipts_on_user_id", using: :btree

  create_table "reputation_events", force: :cascade do |t|
    t.integer  "points"
    t.integer  "user_id"
    t.string   "event_name"
    t.integer  "event_model_id"
    t.string   "event_model_type"
    t.datetime "event_date"
  end

  add_index "reputation_events", ["user_id"], name: "index_reputation_events_on_user_id", using: :btree

  create_table "reputations", force: :cascade do |t|
    t.float    "points",            default: 0.0
    t.integer  "user_id",                         null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "redeemed_points",   default: 0
    t.integer  "redeemable_points", default: 0
  end

  add_index "reputations", ["user_id"], name: "index_reputations_on_user_id", using: :btree

  create_table "respects", force: :cascade do |t|
    t.integer  "user_id",                                         null: false
    t.integer  "respectable_id",                                  null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "respectable_type", limit: 15, default: "Project", null: false
  end

  add_index "respects", ["respectable_id", "respectable_type"], name: "index_respects_on_respectable_id_and_respectable_type", using: :btree
  add_index "respects", ["user_id"], name: "index_respects_on_user_id", using: :btree

  create_table "review_decisions", force: :cascade do |t|
    t.integer  "user_id",          null: false
    t.string   "decision"
    t.hstore   "feedback"
    t.boolean  "approved"
    t.integer  "review_thread_id", null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "review_decisions", ["review_thread_id"], name: "index_review_decisions_on_review_thread_id", using: :btree
  add_index "review_decisions", ["user_id"], name: "index_review_decisions_on_user_id", using: :btree

  create_table "review_events", force: :cascade do |t|
    t.integer  "user_id",          default: 0, null: false
    t.integer  "review_thread_id",             null: false
    t.string   "event"
    t.hstore   "meta"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "review_events", ["review_thread_id"], name: "index_review_events_on_review_thread_id", using: :btree
  add_index "review_events", ["user_id"], name: "index_review_events_on_user_id", using: :btree

  create_table "review_threads", force: :cascade do |t|
    t.integer  "project_id",                     null: false
    t.string   "workflow_state"
    t.boolean  "locked",         default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "review_threads", ["project_id"], name: "index_review_threads_on_project_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.integer  "user_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", using: :btree

  create_table "short_links", force: :cascade do |t|
    t.string   "slug",              limit: 30
    t.string   "redirect_to_url"
    t.integer  "impressions_count"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "short_links", ["slug"], name: "index_short_links_on_slug", using: :btree

  create_table "slug_histories", force: :cascade do |t|
    t.string   "value",          limit: 255,                     null: false
    t.integer  "sluggable_id",                                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sluggable_type", limit: 255, default: "Project", null: false
  end

  add_index "slug_histories", ["id"], name: "index_slug_histories_on_value_lower", using: :btree
  add_index "slug_histories", ["sluggable_type", "sluggable_id"], name: "index_slug_histories_on_sluggable_type_and_sluggable_id", using: :btree

  create_table "store_products", force: :cascade do |t|
    t.integer  "source_id",                      null: false
    t.string   "source_type",                    null: false
    t.integer  "unit_cost",      default: 0
    t.hstore   "counters_cache"
    t.boolean  "available",      default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.hstore   "properties"
    t.string   "name"
    t.text     "description"
  end

  add_index "store_products", ["available"], name: "index_store_products_on_available", using: :btree
  add_index "store_products", ["source_id", "source_type"], name: "index_store_products_on_source_id_and_source_type", using: :btree
  add_index "store_products", ["unit_cost"], name: "index_store_products_on_unit_cost", using: :btree

  create_table "subdomains", force: :cascade do |t|
    t.string   "subdomain",   limit: 255
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "domain",      limit: 255
    t.integer  "platform_id"
    t.text     "properties"
  end

  add_index "subdomains", ["domain"], name: "index_subdomains_on_domain", using: :btree
  add_index "subdomains", ["platform_id"], name: "index_subdomains_on_platform_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer  "taggable_id",               null: false
    t.string   "taggable_type", limit: 255, null: false
    t.string   "type",          limit: 255, null: false
    t.string   "name",          limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "tags", ["taggable_id", "taggable_type", "type"], name: "index_taggable", using: :btree

  create_table "thoughts", force: :cascade do |t|
    t.text     "body"
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link"
    t.text     "raw_body"
  end

  add_index "thoughts", ["user_id"], name: "index_thoughts_on_user_id", using: :btree

  create_table "threads", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.text     "body"
    t.integer  "threadable_id",                               null: false
    t.string   "threadable_type", limit: 255,                 null: false
    t.boolean  "private"
    t.integer  "user_id",                                     null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "type",            limit: 20
    t.string   "workflow_state",  limit: 255
    t.integer  "sub_id",                      default: 0,     null: false
    t.string   "slug",            limit: 255
    t.boolean  "draft",                       default: false
    t.datetime "published_at"
    t.datetime "display_until"
    t.hstore   "hproperties"
  end

  add_index "threads", ["draft"], name: "index_threads_on_draft", using: :btree
  add_index "threads", ["sub_id", "threadable_id", "threadable_type"], name: "threadable_sub_ids", using: :btree
  add_index "threads", ["threadable_id", "threadable_type"], name: "index_blog_posts_on_bloggable_id_and_bloggable_type", using: :btree
  add_index "threads", ["user_id"], name: "index_blog_posts_on_user_id", using: :btree

  create_table "user_activities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "event",            limit: 255
    t.datetime "created_at"
    t.string   "ip"
    t.string   "session_id",       limit: 40
    t.string   "request_url"
    t.string   "referrer_url"
    t.string   "landing_url"
    t.string   "initial_referrer"
  end

  create_table "users", force: :cascade do |t|
    t.string   "user_name",              limit: 100
    t.string   "mini_resume",            limit: 160
    t.string   "city",                   limit: 50
    t.string   "country",                limit: 50
    t.integer  "roles_mask"
    t.string   "email",                  limit: 255, default: "",     null: false
    t.string   "encrypted_password",     limit: 255, default: ""
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "full_name",              limit: 255
    t.text     "websites"
    t.integer  "categories_mask"
    t.string   "invitation_token",       limit: 255
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type",        limit: 255
    t.string   "type",                   limit: 255, default: "User", null: false
    t.integer  "invite_code_id"
    t.integer  "impressions_count",                  default: 0
    t.text     "counters_cache"
    t.text     "properties"
    t.datetime "invitation_created_at"
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "subscriptions_mask",                 default: 0
    t.boolean  "mailchimp_registered",               default: false
    t.string   "authentication_token",   limit: 25
    t.boolean  "enable_sharing",                     default: true,   null: false
    t.string   "platform",               limit: 255
    t.datetime "last_seen_at"
    t.hstore   "subscriptions_masks",                default: {},     null: false
    t.hstore   "hcounters_cache"
    t.hstore   "hproperties"
    t.boolean  "private",                            default: false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "hid",                    limit: 16
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["enable_sharing"], name: "index_users_on_enable_sharing", using: :btree
  add_index "users", ["hid"], name: "index_users_on_hid", using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["private"], name: "index_users_on_private", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["type"], name: "index_users_on_type", using: :btree

  create_table "widgets", force: :cascade do |t|
    t.string   "type",            limit: 255,                     null: false
    t.text     "properties"
    t.string   "name",            limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "project_id",                  default: 0,         null: false
    t.string   "position",        limit: 255, default: "",        null: false
    t.integer  "widgetable_id"
    t.string   "widgetable_type", limit: 255, default: "Project"
  end

  add_index "widgets", ["position"], name: "index_widgets_on_position", using: :btree
  add_index "widgets", ["project_id"], name: "index_widgets_on_project_id", using: :btree

  add_foreign_key "group_impressions", "groups"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "part_impressions", "parts"
  add_foreign_key "project_impressions", "projects"
end
