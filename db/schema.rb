# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100301211322) do

  create_table "accounts", :force => true do |t|
    t.string   "name",              :limit => 100
    t.string   "code",              :limit => 10
    t.float    "open_balance",                     :default => 0.0
    t.datetime "open_balance_date"
    t.boolean  "status",                           :default => true
    t.text     "description"
    t.float    "balance",                          :default => 0.0
    t.integer  "parent_id"
    t.integer  "accounts_count",                   :default => 0
  end

  create_table "approval_queues", :force => true do |t|
    t.integer  "uploaded_by"
    t.boolean  "approved",                      :default => false
    t.text     "rejecton_reason"
    t.integer  "actioned_by"
    t.datetime "actioned_at"
    t.datetime "created_at"
    t.integer  "approvable_id"
    t.string   "approvable_type", :limit => 30
  end

  add_index "approval_queues", ["uploaded_by"], :name => "aq_uploaded_by"
  add_index "approval_queues", ["actioned_by"], :name => "aq_actioned_by"
  add_index "approval_queues", ["approvable_id"], :name => "index_approval_queues_on_approvable_id"

  create_table "article_categories", :force => true do |t|
    t.string   "name",           :limit => 100
    t.text     "description"
    t.datetime "created_at"
    t.integer  "articles_count",                :default => 0
  end

  create_table "article_revisions", :force => true do |t|
    t.integer  "article_id"
    t.integer  "user_id"
    t.integer  "revision",   :default => 0
    t.datetime "created_at"
    t.text     "body"
  end

  add_index "article_revisions", ["article_id"], :name => "index_article_revisions_on_article_id"
  add_index "article_revisions", ["user_id"], :name => "index_article_revisions_on_user_id"

  create_table "articles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "article_category_id"
    t.string   "title",               :limit => 200
    t.integer  "reads_count",                        :default => 0
    t.integer  "comments_count",                     :default => 0
    t.integer  "ratings_count",                      :default => 0
    t.integer  "rating_total",                       :default => 0
    t.datetime "created_at"
    t.integer  "active",                             :default => 1
    t.integer  "approved",                           :default => 0
    t.datetime "approved_date"
    t.integer  "approved_by"
    t.integer  "approved_rev"
    t.integer  "revs_count",                         :default => 0
    t.integer  "diggable",                           :default => 1
    t.integer  "commentable",                        :default => 1
    t.integer  "rateable",                           :default => 1
    t.integer  "bookmarkable",                       :default => 1
    t.integer  "strict_revs",                        :default => 0
  end

  add_index "articles", ["user_id"], :name => "index_articles_on_user_id"
  add_index "articles", ["article_category_id"], :name => "index_articles_on_article_category_id"
  add_index "articles", ["approved_by"], :name => "index_articles_on_approved_by"

  create_table "bad_words", :force => true do |t|
    t.string   "word"
    t.integer  "replaced_count", :default => 0
    t.datetime "created_at"
  end

  add_index "bad_words", ["word"], :name => "index_bad_words_on_word"

  create_table "bans", :force => true do |t|
    t.string   "ip",         :limit => 20
    t.string   "reason",     :limit => 150
    t.integer  "expires_at"
    t.datetime "created_at"
  end

  add_index "bans", ["ip"], :name => "index_bans_on_ip"

  create_table "blogs", :force => true do |t|
    t.integer  "user_id",        :default => 0, :null => false
    t.string   "title"
    t.text     "body"
    t.integer  "blog_read",      :default => 0
    t.datetime "created_at"
    t.integer  "comments_count", :default => 0
  end

  add_index "blogs", ["user_id"], :name => "user_id"

  create_table "categories", :force => true do |t|
    t.integer "parent_id"
    t.string  "name",          :limit => 100
    t.text    "description"
    t.integer "members_count",                :default => 0
  end

  add_index "categories", ["name"], :name => "name"

  create_table "categories_members", :force => true do |t|
    t.integer  "category_id"
    t.integer  "member_id"
    t.string   "member_type", :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories_members", ["category_id"], :name => "index_categories_members_on_category_id"
  add_index "categories_members", ["member_id"], :name => "index_categories_members_on_member_id"

  create_table "club_members", :force => true do |t|
    t.integer  "club_id"
    t.integer  "user_id"
    t.string   "member_title", :limit => 200
    t.datetime "created_at"
    t.integer  "status",                      :default => 0
    t.datetime "status_date"
    t.text     "application"
  end

  add_index "club_members", ["club_id"], :name => "index_club_members_on_club_id"
  add_index "club_members", ["user_id"], :name => "index_club_members_on_user_id"

  create_table "clubs", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",          :limit => 200
    t.text     "description"
    t.datetime "created_at"
    t.integer  "club_type"
    t.integer  "members_count",                :default => 0
    t.text     "address"
    t.string   "country",       :limit => 60
    t.string   "county",        :limit => 60
  end

  add_index "clubs", ["user_id"], :name => "index_clubs_on_user_id"

  create_table "collections", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.float    "price",                  :default => 0.0
    t.datetime "created_at"
    t.integer  "collection_items_count", :default => 0
    t.integer  "download_count",         :default => 0
    t.integer  "sold_count",             :default => 0
    t.float    "total_sales",            :default => 0.0
    t.integer  "view_count",             :default => 0
    t.integer  "collection_size",        :default => 0
    t.integer  "comments_count",         :default => 0
    t.integer  "ratings_count",          :default => 0
    t.integer  "rating_total",           :default => 0
  end

  add_index "collections", ["user_id"], :name => "index_collections_on_user_id"

  create_table "collections_items", :force => true do |t|
    t.integer  "collection_id"
    t.datetime "created_at"
    t.datetime "created_on"
    t.integer  "item_id"
    t.string   "item_type",     :limit => 30
  end

  add_index "collections_items", ["collection_id"], :name => "index_collection_items_on_collection_id"
  add_index "collections_items", ["item_id"], :name => "index_collection_items_on_collectionable_id"

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "body"
    t.datetime "created_at",                                        :null => false
    t.integer  "commentable_id",                 :default => 0,     :null => false
    t.string   "commentable_type", :limit => 15, :default => "",    :null => false
    t.integer  "user_id",                        :default => 0,     :null => false
    t.string   "ip",               :limit => 15
    t.string   "dns"
    t.boolean  "checked"
    t.datetime "checked_at"
    t.integer  "checked_by"
    t.boolean  "spam",                           :default => false
    t.string   "anon_name",        :limit => 30
    t.string   "anon_url",         :limit => 60
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "commentable_id"
  add_index "comments", ["user_id"], :name => "user_id"
  add_index "comments", ["ip"], :name => "ip"

  create_table "credit_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "journal_id"
    t.float    "value"
    t.datetime "created_at"
    t.integer  "order_id"
    t.string   "description"
    t.integer  "credit_type"
  end

  add_index "credit_histories", ["user_id"], :name => "credit_histories_user_id_index"
  add_index "credit_histories", ["journal_id"], :name => "credit_histories_journal_id_index"
  add_index "credit_histories", ["order_id"], :name => "credit_histories_order_id_index"

  create_table "favourites", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.text     "note"
    t.integer  "favouriteable_id"
    t.string   "favouriteable_type", :limit => 20
  end

  add_index "favourites", ["user_id"], :name => "user_id"
  add_index "favourites", ["favouriteable_id", "favouriteable_type"], :name => "i_favourites"

  create_table "forum_categories", :force => true do |t|
    t.string "name",        :limit => 200, :default => "", :null => false
    t.text   "description"
  end

  create_table "forum_posts", :force => true do |t|
    t.integer  "forum_id",               :default => 0, :null => false
    t.integer  "user_id"
    t.text     "comment"
    t.datetime "date"
    t.string   "ip",       :limit => 15
  end

  add_index "forum_posts", ["forum_id"], :name => "forum_id"
  add_index "forum_posts", ["user_id"], :name => "user_id"

  create_table "forums", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "topics_count", :default => 0
    t.integer  "posts_count",  :default => 0
    t.integer  "position"
    t.datetime "last_posted"
    t.integer  "club_id"
    t.integer  "access_level"
    t.integer  "created_by"
    t.datetime "created_at"
  end

  add_index "forums", ["club_id"], :name => "index_forums_on_club_id"
  add_index "forums", ["created_by"], :name => "index_forums_on_created_by"

  create_table "friends", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.string   "comments",   :limit => 150
  end

  add_index "friends", ["user_id"], :name => "friends_user_id_index"
  add_index "friends", ["friend_id"], :name => "friends_friend_id_index"

  create_table "host_plans", :force => true do |t|
    t.string  "name",          :limit => 50
    t.text    "description"
    t.integer "disk_space"
    t.float   "monthly_fee"
    t.integer "default_plan",                :default => 0
    t.integer "commerce",                    :default => 0
    t.integer "blog",                        :default => 0
    t.integer "price_setting",               :default => 0
    t.integer "license",                     :default => 0
    t.integer "club",                        :default => 0
  end

  create_table "jobs", :force => true do |t|
    t.string   "worker_class"
    t.string   "worker_method"
    t.text     "args"
    t.integer  "priority"
    t.integer  "progress"
    t.string   "state"
    t.integer  "lock_version"
    t.datetime "start_at"
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "result"
    t.string   "queue",         :limit => 10
    t.string   "job_title",     :limit => 100
  end

  add_index "jobs", ["state"], :name => "index_jobs_on_state"
  add_index "jobs", ["start_at"], :name => "index_jobs_on_start_at"
  add_index "jobs", ["priority"], :name => "index_jobs_on_priority"
  add_index "jobs", ["created_at"], :name => "index_jobs_on_created_at"

  create_table "journals", :force => true do |t|
    t.integer  "journal_type"
    t.datetime "created_at"
  end

  create_table "licenses", :force => true do |t|
    t.string  "name",          :limit => 100
    t.integer "user_id",                      :default => 0
    t.text    "description"
    t.float   "default_price",                :default => 1.0
  end

  add_index "licenses", ["user_id"], :name => "index_licenses_on_user_id"

  create_table "lightboxes", :force => true do |t|
    t.integer  "link_id"
    t.datetime "created_at"
    t.text     "note"
    t.integer  "user_id"
    t.integer  "downloaded",               :default => 0
    t.integer  "viewed",                   :default => 0
    t.string   "link_type",  :limit => 20
  end

  add_index "lightboxes", ["link_id"], :name => "photo_id"
  add_index "lightboxes", ["user_id"], :name => "lightboxes_user_id_index"
  add_index "lightboxes", ["link_id"], :name => "index_lightboxes_on_link_id"

  create_table "links", :force => true do |t|
    t.string   "name",           :limit => 200
    t.string   "link",           :limit => 200
    t.text     "description"
    t.integer  "votes_up",                      :default => 0
    t.integer  "votes_down",                    :default => 0
    t.integer  "views",                         :default => 0
    t.integer  "visits",                        :default => 0
    t.integer  "comments_count",                :default => 0
    t.integer  "saved_count",                   :default => 0
    t.boolean  "active",                        :default => true
    t.integer  "user_id"
    t.datetime "created_at"
    t.string   "screen_shot",    :limit => 254
    t.integer  "rank"
  end

  add_index "links", ["user_id"], :name => "index_links_on_user_id"

  create_table "markers", :force => true do |t|
    t.integer  "markable_id",                                                 :default => 0, :null => false
    t.string   "markable_type", :limit => 50
    t.integer  "user_id"
    t.string   "title",         :limit => 100
    t.decimal  "long",                         :precision => 11, :scale => 8
    t.decimal  "lat",                          :precision => 11, :scale => 8
    t.integer  "level"
    t.datetime "created_at"
  end

  add_index "markers", ["markable_id", "markable_type"], :name => "index_markers_on_markable_id_and_markable_type"
  add_index "markers", ["user_id"], :name => "index_markers_on_user_id"
  add_index "markers", ["long"], :name => "index_markers_on_long"
  add_index "markers", ["lat"], :name => "index_markers_on_lat"

  create_table "media_license_prices", :force => true do |t|
    t.integer  "media_id"
    t.integer  "license_id"
    t.float    "price"
    t.datetime "created_at"
    t.integer  "user_id"
  end

  add_index "media_license_prices", ["media_id"], :name => "plp_photo_id"
  add_index "media_license_prices", ["license_id"], :name => "plp_license_id"
  add_index "media_license_prices", ["user_id"], :name => "plp_user_id"

  create_table "medias", :force => true do |t|
    t.integer  "extended_info_id",                :default => 0,    :null => false
    t.integer  "user_id",                         :default => 0,    :null => false
    t.string   "title",            :limit => 200, :default => "",   :null => false
    t.text     "description"
    t.text     "text_tags"
    t.integer  "views_count",                     :default => 0
    t.integer  "comments_count",                  :default => 0
    t.integer  "downloads",                       :default => 0
    t.integer  "ratings_count",                   :default => 0
    t.integer  "sold_count",                      :default => 0
    t.integer  "previews_count",                  :default => 0
    t.integer  "favourites_count",                :default => 0
    t.integer  "rating_total",                    :default => 0
    t.float    "sold_value",                      :default => 0.0
    t.float    "price",                           :default => 0.0
    t.integer  "width"
    t.integer  "height"
    t.integer  "file_size"
    t.string   "filename"
    t.text     "exif"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.datetime "approved_on"
    t.string   "approved_by",      :limit => 30
    t.string   "file_type"
    t.integer  "license_id"
    t.integer  "private",                         :default => 0
    t.boolean  "approved",                        :default => true
    t.float    "aspect_ratio"
    t.integer  "state",                           :default => 0
    t.integer  "job_id"
    t.string   "orig_file_ext",    :limit => 10
    t.string   "type",             :limit => 15
    t.integer  "duration",                        :default => 0
    t.integer  "bitrate",                         :default => 0
    t.integer  "preview_width"
    t.integer  "preview_height"
  end

  add_index "medias", ["extended_info_id"], :name => "extended_info_id"
  add_index "medias", ["user_id"], :name => "photographer_id"
  add_index "medias", ["title"], :name => "title"
  add_index "medias", ["license_id"], :name => "index_photos_on_license_id"
  add_index "medias", ["created_on"], :name => "index_photos_on_created_on"
  add_index "medias", ["aspect_ratio"], :name => "index_photos_on_aspect_ratio"
  add_index "medias", ["job_id"], :name => "index_photos_on_job_id"

  create_table "menu_items", :force => true do |t|
    t.integer "menu_id"
    t.integer "parent_id"
    t.string  "name",        :limit => 100
    t.integer "link_type",                  :default => 0
    t.string  "link_url",    :limit => 200
    t.string  "description", :limit => 200
    t.integer "position"
    t.string  "conditions",  :limit => 200
    t.boolean "visible",                    :default => true
    t.string  "controller",  :limit => 100
    t.string  "action",      :limit => 100
  end

  add_index "menu_items", ["name"], :name => "index_menu_items_on_name"
  add_index "menu_items", ["menu_id"], :name => "index_menu_items_on_menu_id"
  add_index "menu_items", ["parent_id"], :name => "index_menu_items_on_parent_id"

  create_table "menus", :force => true do |t|
    t.string "name",        :limit => 50
    t.string "description", :limit => 200
  end

  add_index "menus", ["name"], :name => "index_menus_on_name"

  create_table "migrations_info", :force => true do |t|
    t.datetime "created_at"
  end

  create_table "news_histories", :force => true do |t|
    t.integer  "club_id"
    t.integer  "user_id"
    t.integer  "news_item_id"
    t.datetime "created_at"
  end

  add_index "news_histories", ["club_id"], :name => "index_news_histories_on_club_id"
  add_index "news_histories", ["user_id"], :name => "index_news_histories_on_user_id"
  add_index "news_histories", ["news_item_id"], :name => "index_news_histories_on_news_item_id"

  create_table "news_items", :force => true do |t|
    t.integer  "user_id",                      :default => 0,     :null => false
    t.string   "title",                        :default => "",    :null => false
    t.datetime "created_at"
    t.text     "body",                                            :null => false
    t.text     "extra"
    t.datetime "expire_date"
    t.integer  "read",                         :default => 0
    t.boolean  "expire_item",                  :default => false
    t.boolean  "active",                       :default => false
    t.integer  "comments_count",               :default => 0
    t.integer  "itemable_id"
    t.string   "itemable_type",  :limit => 50
  end

  add_index "news_items", ["itemable_id"], :name => "index_news_items_on_itemable_id"

  create_table "news_topics", :force => true do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "notifications", :force => true do |t|
    t.integer "user_id"
    t.integer "notifiable_id"
    t.string  "notifiable_type", :limit => 50
    t.string  "event",           :limit => 50
    t.boolean "enabled",                       :default => true
  end

  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"
  add_index "notifications", ["notifiable_id"], :name => "index_notifications_on_notifiable_id"
  add_index "notifications", ["notifiable_type", "event"], :name => "index_notifications_on_notifiable_type_and_event"

  create_table "order_items", :force => true do |t|
    t.integer  "order_id",                   :default => 0, :null => false
    t.integer  "item_id",                    :default => 0, :null => false
    t.integer  "item_type"
    t.integer  "qty"
    t.float    "value"
    t.datetime "created_at"
    t.string   "description", :limit => 200
  end

  add_index "order_items", ["order_id"], :name => "order_id"
  add_index "order_items", ["item_id"], :name => "item_id"

  create_table "order_logs", :force => true do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.integer  "log_type"
    t.datetime "created_at"
    t.text     "notify_yaml"
    t.text     "raw_log"
  end

  add_index "order_logs", ["order_id"], :name => "index_order_logs_on_order_id"
  add_index "order_logs", ["user_id"], :name => "index_order_logs_on_user_id"

  create_table "orders", :force => true do |t|
    t.integer  "user_id",                         :null => false
    t.integer  "status"
    t.string   "gate_transaction", :limit => 50
    t.string   "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "customer_ip",      :limit => 15
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state",            :limit => 30
    t.string   "country",          :limit => 5
    t.string   "zip",              :limit => 20
    t.string   "purchase_order",   :limit => 100
    t.text     "address"
  end

  add_index "orders", ["user_id"], :name => "user_id"

  create_table "pages", :force => true do |t|
    t.string   "name",         :limit => 50
    t.text     "content"
    t.integer  "content_type",               :default => 0
    t.boolean  "visible",                    :default => true
    t.integer  "viewed",                     :default => 0
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["name"], :name => "index_pages_on_name"

  create_table "photo_price_levels", :force => true do |t|
    t.integer "sales"
    t.float   "price"
  end

  create_table "photo_resolution_price_defaults", :force => true do |t|
    t.string  "name",        :limit => 50
    t.text    "description"
    t.integer "width"
    t.integer "height"
    t.integer "pixel_area"
    t.float   "price"
  end

  create_table "photo_resolution_prices", :force => true do |t|
    t.integer "photo_id"
    t.integer "photo_resolution_price_default_id"
    t.integer "width"
    t.integer "height"
    t.integer "pixel_area"
    t.float   "price"
  end

  add_index "photo_resolution_prices", ["photo_id"], :name => "prp_photo_id"
  add_index "photo_resolution_prices", ["photo_resolution_price_default_id"], :name => "prp_default_id"

  create_table "postings", :force => true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.integer  "journal_id"
    t.string   "our_ref"
    t.string   "their_ref"
    t.datetime "created_at"
    t.string   "year"
    t.string   "month"
    t.float    "value",      :default => 0.0
    t.boolean  "paid",       :default => false
  end

  add_index "postings", ["account_id"], :name => "postings_account_id_index"
  add_index "postings", ["user_id"], :name => "postings_user_id_index"
  add_index "postings", ["journal_id"], :name => "postings_journal_id_index"
  add_index "postings", ["our_ref"], :name => "postings_our_ref_index"
  add_index "postings", ["their_ref"], :name => "postings_their_ref_index"

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.string   "poster_ip",  :limit => 20
    t.string   "title",      :limit => 200
  end

  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  add_index "posts", ["forum_id", "created_at"], :name => "index_posts_on_forum_id"

  create_table "promotion_emails", :force => true do |t|
    t.integer  "promotion_id"
    t.string   "email",        :limit => 50
    t.datetime "claimed_date"
    t.datetime "created_at"
    t.float    "sale_value",                 :default => 0.0
    t.string   "token",        :limit => 50
  end

  add_index "promotion_emails", ["promotion_id"], :name => "promotions_emails_promotion_id_index"
  add_index "promotion_emails", ["token"], :name => "index_promotion_emails_on_token"

  create_table "promotion_users", :force => true do |t|
    t.integer  "promotion_id"
    t.integer  "user_id"
    t.datetime "created_at"
  end

  add_index "promotion_users", ["promotion_id"], :name => "promotions_users_promotion_id_index"
  add_index "promotion_users", ["user_id"], :name => "promotions_users_user_id_index"

  create_table "promotions", :force => true do |t|
    t.integer  "link_id"
    t.string   "code",           :limit => 75
    t.string   "vendor_ref",     :limit => 50
    t.float    "credits",                      :default => 0.0
    t.integer  "uses_remaining",               :default => 1
    t.datetime "created_at"
    t.boolean  "strict",                       :default => false
    t.string   "link_type",      :limit => 20
    t.datetime "expires_at"
  end

  add_index "promotions", ["link_id"], :name => "promotions_photo_id_index"
  add_index "promotions", ["code"], :name => "promotions_code_index"
  add_index "promotions", ["vendor_ref"], :name => "promotions_vendor_ref_index"

  create_table "protector_hits", :force => true do |t|
    t.string   "ip",         :limit => 15
    t.string   "url",        :limit => 50
    t.integer  "expire"
    t.datetime "created_at"
  end

  add_index "protector_hits", ["ip"], :name => "index_protector_hits_on_ip"
  add_index "protector_hits", ["url"], :name => "index_protector_hits_on_url"
  add_index "protector_hits", ["expire"], :name => "index_protector_hits_on_expire"

  create_table "protector_logs", :force => true do |t|
    t.string   "ip",         :limit => 15
    t.string   "dns",        :limit => 100
    t.string   "log",        :limit => 100
    t.datetime "created_at"
  end

  add_index "protector_logs", ["ip"], :name => "index_protector_logs_on_ip"

  create_table "ranks", :force => true do |t|
    t.integer "posts",               :default => 0,  :null => false
    t.string  "name",  :limit => 20, :default => "", :null => false
    t.string  "image",               :default => "", :null => false
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rating",                      :default => 0
    t.datetime "created_at",                                  :null => false
    t.string   "rateable_type", :limit => 15, :default => "", :null => false
    t.integer  "rateable_id",                 :default => 0,  :null => false
    t.integer  "user_id",                     :default => 0,  :null => false
    t.string   "ip",            :limit => 15, :default => "", :null => false
    t.string   "dns"
  end

  add_index "ratings", ["user_id"], :name => "user_id"
  add_index "ratings", ["ip"], :name => "ip"
  add_index "ratings", ["rateable_id"], :name => "index_ratings_on_rateable_id"

  create_table "rejection_reasons", :force => true do |t|
    t.string "name"
    t.text   "reason"
  end

  create_table "report_image_types", :force => true do |t|
    t.string  "report_type"
    t.text    "description"
    t.boolean "default_type", :default => false
  end

  create_table "report_images", :force => true do |t|
    t.integer  "report_type_id"
    t.integer  "reported_by"
    t.integer  "actioned_by"
    t.integer  "reportable_id"
    t.string   "reportable_type", :limit => 30
    t.text     "description"
    t.text     "action"
    t.datetime "actioned"
    t.datetime "created_at"
  end

  add_index "report_images", ["reported_by"], :name => "index_report_images_on_reported_by"
  add_index "report_images", ["actioned_by"], :name => "index_report_images_on_actioned_by"
  add_index "report_images", ["reportable_id"], :name => "index_report_images_on_reportable_id"
  add_index "report_images", ["report_type_id"], :name => "index_report_images_on_report_type_id"

  create_table "rss_feed_items", :force => true do |t|
    t.integer  "rss_feed_id"
    t.string   "url",            :limit => 200
    t.string   "title",          :limit => 200
    t.text     "summary"
    t.text     "content"
    t.datetime "published"
    t.integer  "comments_count",                :default => 0
    t.boolean  "active",                        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "views_count",                   :default => 0
  end

  add_index "rss_feed_items", ["rss_feed_id"], :name => "fk_feed"
  add_index "rss_feed_items", ["url"], :name => "index_rss_feed_items_on_url"

  create_table "rss_feeds", :force => true do |t|
    t.string   "name",             :limit => 100
    t.text     "description"
    t.string   "url",              :limit => 200
    t.integer  "display_order",                   :default => 0
    t.integer  "limit_items",                     :default => 5
    t.integer  "rss_type"
    t.integer  "visible",                         :default => 1
    t.text     "feed"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.datetime "last_feed_date"
    t.boolean  "sanitise",                        :default => false
    t.string   "update_frequency"
    t.datetime "next_update"
  end

  create_table "rss_stats", :force => true do |t|
    t.integer "link_id"
    t.string  "link_type",  :limit => 25
    t.integer "sub_count",                :default => 0
    t.integer "read_count",               :default => 0
  end

  add_index "rss_stats", ["link_id"], :name => "index_rss_stats_on_link_id"

  create_table "rss_subscription_ips", :force => true do |t|
    t.integer  "rss_stats_id"
    t.string   "ip",           :limit => 15
    t.datetime "created_at"
  end

  add_index "rss_subscription_ips", ["rss_stats_id"], :name => "index_rss_subscription_ips_on_rss_stats_id"
  add_index "rss_subscription_ips", ["ip"], :name => "index_rss_subscription_ips_on_ip"

  create_table "sale_orders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "journal_id"
    t.datetime "payment_due"
    t.float    "value"
    t.datetime "paid_date"
    t.float    "paid_amount"
    t.string   "paypal_email",         :limit => 100
    t.integer  "paypal_status"
    t.string   "paypal_ref",           :limit => 50
    t.text     "paypal_responce"
    t.datetime "paypal_responce_date"
    t.datetime "created_at"
  end

  add_index "sale_orders", ["user_id"], :name => "sale_orders_user_id_index"
  add_index "sale_orders", ["journal_id"], :name => "sale_orders_journal_id_index"
  add_index "sale_orders", ["paypal_ref"], :name => "sale_orders_paypal_ref_index"

  create_table "server_task_logs", :force => true do |t|
    t.integer  "server_task_id"
    t.text     "log"
    t.datetime "created_at"
  end

  add_index "server_task_logs", ["server_task_id"], :name => "task_id"

  create_table "server_tasks", :force => true do |t|
    t.string   "task",         :limit => 30
    t.integer  "taskable_id"
    t.boolean  "completed",                  :default => false
    t.datetime "completed_at"
    t.datetime "created_at"
    t.text     "log"
    t.datetime "next_run"
    t.string   "period",       :limit => 60
    t.string   "retry_period", :limit => 10
    t.string   "extra",        :limit => 20
  end

  add_index "server_tasks", ["taskable_id"], :name => "i_taskable_id"
  add_index "server_tasks", ["next_run"], :name => "index_server_tasks_on_next_run"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "setup_resources", :force => true do |t|
    t.integer "setup_id"
    t.text    "value"
  end

  add_index "setup_resources", ["setup_id"], :name => "index_setup_resources_on_setup_id"

  create_table "setups", :force => true do |t|
    t.string  "key"
    t.integer "type"
    t.string  "value",      :limit => 200
    t.string  "value_type", :limit => 20
  end

  create_table "subscription_failures", :force => true do |t|
    t.integer  "user_id"
    t.integer  "host_plan_id"
    t.datetime "created_at"
  end

  add_index "subscription_failures", ["user_id"], :name => "index_subscription_failures_on_user_id"
  add_index "subscription_failures", ["host_plan_id"], :name => "index_subscription_failures_on_host_plan_id"

  create_table "subscription_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "journal_id"
    t.string   "order_transaction", :limit => 50
    t.float    "value"
    t.datetime "created_at"
  end

  add_index "subscription_histories", ["user_id"], :name => "subscription_histories_user_id_index"
  add_index "subscription_histories", ["journal_id"], :name => "subscription_histories_journal_id_index"
  add_index "subscription_histories", ["order_transaction"], :name => "subscription_histories_transaction_index"

  create_table "swatch_colors", :force => true do |t|
    t.string   "rgb",            :limit => 6
    t.integer  "red"
    t.integer  "green"
    t.integer  "blue"
    t.integer  "swatches_count",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "swatch_colors", ["rgb"], :name => "index_swatch_colors_on_rgb"
  add_index "swatch_colors", ["red"], :name => "index_swatch_colors_on_red"
  add_index "swatch_colors", ["green"], :name => "index_swatch_colors_on_green"
  add_index "swatch_colors", ["blue"], :name => "index_swatch_colors_on_blue"

  create_table "swatch_members", :force => true do |t|
    t.integer "swatch_id"
    t.integer "swatch_color_id"
    t.integer "position"
  end

  add_index "swatch_members", ["swatch_id"], :name => "index_swatch_members_on_swatch_id"
  add_index "swatch_members", ["swatch_color_id"], :name => "index_swatch_members_on_swatch_color_id"

  create_table "swatches", :force => true do |t|
    t.integer  "swatchable_id"
    t.string   "swatchable_type", :limit => 20
    t.integer  "colors_count",                  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "swatches", ["swatchable_id", "swatchable_type"], :name => "swatches_fk"

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
    t.integer "created_by"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "taggings_tag_id_index"
  add_index "taggings", ["taggable_id"], :name => "index_taggings_on_taggable_id"
  add_index "taggings", ["created_by"], :name => "index_taggings_on_created_by"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name"], :name => "tags_name_index"

  create_table "topics", :force => true do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hits",         :default => 0
    t.integer  "sticky",       :default => 0
    t.integer  "posts_count",  :default => 0
    t.datetime "replied_at"
    t.boolean  "locked",       :default => false
    t.integer  "replied_by"
    t.integer  "last_post_id"
  end

  add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"
  add_index "topics", ["sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"

  create_table "user_audio_preferences", :force => true do |t|
    t.integer  "user_id"
    t.integer  "sample_length",    :default => 0
    t.string   "bitrate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "free_full_length"
  end

  add_index "user_audio_preferences", ["user_id"], :name => "user_audio_preferences_user"

  create_table "users", :force => true do |t|
    t.integer  "host_plan_id"
    t.string   "login"
    t.string   "name",                      :limit => 50
    t.string   "email"
    t.string   "state",                     :limit => 50
    t.string   "country",                   :limit => 50
    t.integer  "admin"
    t.float    "credits",                                  :default => 0.0
    t.string   "avatar"
    t.string   "avatar_type",               :limit => 50
    t.integer  "rank"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_seen_at"
    t.datetime "remember_token_expires_at"
    t.string   "remember_token"
    t.integer  "photos_count",                             :default => 0
    t.integer  "posts_count",                              :default => 0
    t.text     "bio"
    t.integer  "disk_space_used",                          :default => 0
    t.integer  "blogs_count",                              :default => 0
    t.integer  "ratings",                                  :default => 0
    t.datetime "last_sub_date"
    t.datetime "next_sub_date"
    t.float    "total_sales",                              :default => 0.0
    t.integer  "friends_count",                            :default => 0
    t.string   "token",                     :limit => 10
    t.boolean  "activated",                                :default => false
    t.boolean  "active",                                   :default => false
    t.integer  "ratings_count",                            :default => 0
    t.string   "paypal_email",              :limit => 100
    t.string   "paypal_sub_id",             :limit => 50
    t.boolean  "special_member",                           :default => false
    t.integer  "videos_count",                             :default => 0
    t.integer  "photo_space_used",                         :default => 0
    t.integer  "video_space_used",                         :default => 0
    t.integer  "audio_space_used",                         :default => 0
    t.integer  "audios_count",                             :default => 0
    t.boolean  "vip",                                      :default => false
    t.boolean  "subscriber",                               :default => false
    t.string   "sent_email_event",          :limit => 250
    t.string   "contact_name",              :limit => 100
    t.string   "contact_number",            :limit => 100
    t.text     "billing_address"
  end

  add_index "users", ["login"], :name => "login"
  add_index "users", ["token"], :name => "users_token_index"
  add_index "users", ["paypal_sub_id"], :name => "index_users_on_paypal_sub_id"
  add_index "users", ["next_sub_date"], :name => "index_users_on_next_sub_date"

end
