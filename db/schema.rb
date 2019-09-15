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

ActiveRecord::Schema.define(version: 2019_08_26_092342) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_id"
    t.text "attendee_info_1"
    t.text "attendee_info_2"
    t.boolean "ticket_needed", default: false, null: false
    t.boolean "travel_needed", default: false, null: false
    t.boolean "accommodation_needed", default: false, null: false
    t.boolean "visa_needed", default: false, null: false
    t.integer "applicant_id"
    t.boolean "submitted", default: false, null: false
    t.string "status", default: "pending"
    t.boolean "terms_and_conditions", default: false, null: false
    t.boolean "deleted", default: false
    t.index ["event_id"], name: "index_applications_on_event_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "organizer_name"
    t.string "organizer_email"
    t.text "description"
    t.text "name"
    t.date "start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "end_date"
    t.boolean "approved", default: false, null: false
    t.text "website"
    t.text "code_of_conduct"
    t.string "city"
    t.string "country"
    t.datetime "deadline"
    t.integer "number_of_tickets"
    t.boolean "ticket_funded", default: false, null: false
    t.boolean "accommodation_funded", default: false, null: false
    t.boolean "travel_funded", default: false, null: false
    t.text "applicant_directions"
    t.text "logo"
    t.text "application_link"
    t.string "application_process"
    t.string "twitter_handle"
    t.string "state_province"
    t.integer "organizer_id"
    t.boolean "deleted", default: false
    t.integer "approved_tickets", default: 0
    t.integer "capacity_reminder_count", default: 0
    t.index ["organizer_id"], name: "index_events_on_organizer_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["event_id"], name: "index_taggings_on_event_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_tags_on_category_id"
  end

  create_table "tweets", force: :cascade do |t|
    t.bigint "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: true
    t.index ["event_id"], name: "index_tweets_on_event_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.boolean "admin", default: false, null: false
    t.string "name"
    t.boolean "country_email_notifications", default: false
    t.string "country"
    t.boolean "tag_email_notifications", default: false
    t.string "capacity_email_notifications", default: "OFF"
    t.boolean "privacy_policy_agreement", default: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "applications", "events"
  add_foreign_key "events", "users", column: "organizer_id"
end
