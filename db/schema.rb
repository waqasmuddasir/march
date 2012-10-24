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

ActiveRecord::Schema.define(:version => 20110122080040) do

  create_table "admins", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_super",   :default => false
  end

  create_table "api_messages", :force => true do |t|
    t.string   "status"
    t.integer  "code"
    t.string   "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "areas", :force => true do |t|
    t.string   "name",       :limit => 100, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "company"
    t.text     "address"
    t.string   "country"
    t.string   "city"
    t.string   "phone"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_files", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_records", :force => true do |t|
    t.string   "sender"
    t.string   "recipient"
    t.string   "subject"
    t.text     "body"
    t.integer  "merchant_package_id"
    t.integer  "email_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_template_types", :force => true do |t|
    t.string   "template_type", :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_template_types", ["template_type"], :name => "index_email_template_types_on_type", :unique => true

  create_table "email_templates", :force => true do |t|
    t.string   "name",                    :limit => 100
    t.string   "subject",                 :limit => 250
    t.text     "content"
    t.integer  "email_template_types_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_templates", ["name"], :name => "index_email_templates_on_name", :unique => true

  create_table "event_logs", :force => true do |t|
    t.string   "event_class"
    t.integer  "event_action"
    t.string   "event_body"
    t.integer  "user_id"
    t.integer  "merchant_package_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_shown",            :default => false
  end

  create_table "group_chats", :force => true do |t|
    t.string   "sender"
    t.string   "contents"
    t.string   "in_number"
    t.string   "user_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_member_leaves", :force => true do |t|
    t.integer  "user_group_id"
    t.string   "mobile"
    t.string   "name"
    t.integer  "package_id"
    t.integer  "host_user_id"
    t.integer  "group_number_id"
    t.boolean  "is_active"
    t.boolean  "is_blocked"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_members", :force => true do |t|
    t.integer  "user_group_id"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mobile"
    t.string   "name"
    t.integer  "package_id"
    t.boolean  "is_blocked",      :default => false
    t.integer  "host_user_id"
    t.integer  "group_number_id"
  end

  create_table "group_numbers", :force => true do |t|
    t.string   "group_name"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ipcontents", :force => true do |t|
    t.string  "type"
    t.integer "content_file_prefix"
  end

  create_table "ips", :force => true do |t|
    t.integer "ipnumber"
    t.string  "ip"
    t.integer "ipcontent_id"
  end

  add_index "ips", ["ipcontent_id"], :name => "index_ips_on_ipcontent_id"
  add_index "ips", ["ipnumber"], :name => "index_ips_on_ipnumber"

  create_table "merchant_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merchant_contacts", :force => true do |t|
    t.integer  "merchant_id"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merchant_offerings", :force => true do |t|
    t.integer  "merchant_id"
    t.integer  "offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merchant_package_images", :force => true do |t|
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "merchant_package_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merchant_packages", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "merchant_id"
    t.integer  "offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verification_code"
    t.string   "access_code"
    t.text     "redemption_instructions"
  end

  create_table "merchants", :force => true do |t|
    t.string   "name"
    t.text     "detail"
    t.text     "address"
    t.string   "country"
    t.string   "city"
    t.string   "phone"
    t.integer  "merchant_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "offerings", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "package_allowed_times", :force => true do |t|
    t.integer  "package_rule_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "package_rules", :force => true do |t|
    t.boolean  "is_all_day"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "rule"
    t.integer  "merchant_package_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rule_type"
  end

  create_table "potential_user_email_records", :force => true do |t|
    t.integer  "potential_user_id"
    t.integer  "email_record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "potential_user_packages", :force => true do |t|
    t.integer  "potential_user_id"
    t.integer  "merchant_package_id"
    t.boolean  "is_subscribed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "potential_users", :force => true do |t|
    t.string   "login",         :limit => 40
    t.string   "name",          :limit => 100
    t.string   "email",         :limit => 150,                    :null => false
    t.string   "first_name",    :limit => 100
    t.string   "middle_name",   :limit => 100
    t.string   "last_name",     :limit => 100
    t.string   "company",       :limit => 100
    t.string   "address",       :limit => 200
    t.string   "county",        :limit => 100
    t.string   "post_code",     :limit => 20
    t.string   "mobile",        :limit => 20
    t.boolean  "is_registered",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "area_id"
  end

  create_table "redeemed_packages", :force => true do |t|
    t.integer  "merchant_package_id"
    t.integer  "user_id"
    t.datetime "start_time"
    t.boolean  "is_completed",        :default => false
    t.integer  "verification_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "share_with_friends", :force => true do |t|
    t.string   "sender_name"
    t.string   "sender_email"
    t.string   "friend_name"
    t.string   "friend_email"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "signup_urls", :force => true do |t|
    t.integer  "user_id"
    t.integer  "stored_signup_url_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stored_signup_urls", :force => true do |t|
    t.string   "random_code"
    t.integer  "merchant_package_id"
    t.integer  "group_member_id"
    t.string   "url_string"
    t.datetime "expiry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stored_urls", :force => true do |t|
    t.string   "random_code"
    t.string   "user_auth_token"
    t.integer  "merchant_package_id"
    t.string   "url_string"
    t.datetime "expiry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "txtlocals", :force => true do |t|
    t.string   "sms_type"
    t.string   "message_contents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_groups", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "group_number_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "package_id"
  end

  create_table "user_packages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "merchant_package_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sms_sent"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 150
    t.string   "first_name",                :limit => 100
    t.string   "middle_name",               :limit => 100
    t.string   "last_name",                 :limit => 100
    t.string   "company",                   :limit => 100, :default => ""
    t.string   "address",                   :limit => 200
    t.string   "county",                    :limit => 100
    t.string   "post_code",                 :limit => 20
    t.string   "mobile",                    :limit => 20
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.boolean  "email_notification",                       :default => false, :null => false
    t.string   "auth_token"
    t.boolean  "sms_notification"
    t.string   "password_reset_code"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
