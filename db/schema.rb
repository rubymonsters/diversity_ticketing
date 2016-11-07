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

ActiveRecord::Schema.define(version: 20161121200712) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "event_id"
    t.text     "attendee_info_1"
    t.text     "attendee_info_2"
    t.boolean  "ticket_needed",        default: false, null: false
    t.boolean  "travel_needed",        default: false, null: false
    t.boolean  "accommodation_needed", default: false, null: false
    t.boolean  "visa_needed",          default: false, null: false
  end

  add_index "applications", ["event_id"], name: "index_applications_on_event_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "organizer_name"
    t.string   "organizer_email"
    t.text     "description"
    t.text     "name"
    t.date     "start_date"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.date     "end_date"
    t.boolean  "approved",             default: false, null: false
    t.text     "website"
    t.text     "code_of_conduct"
    t.string   "city"
    t.string   "country"
    t.date     "deadline"
    t.integer  "number_of_tickets"
    t.boolean  "ticket_funded",        default: false, null: false
    t.boolean  "accommodation_funded", default: false, null: false
    t.boolean  "travel_funded",        default: false, null: false
    t.text     "logo"
    t.text     "applicant_directions"
    t.text     "application_link"
    t.string   "application_process"
    t.string   "twitter_handle"
    t.string   "state_province"
    t.integer  "organizer_id"
  end

  add_index "events", ["organizer_id"], name: "index_events_on_organizer_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "taggings", ["event_id"], name: "index_taggings_on_event_id", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "category_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "email",                                          null: false
    t.string   "encrypted_password", limit: 128,                 null: false
    t.string   "confirmation_token", limit: 128
    t.string   "remember_token",     limit: 128,                 null: false
    t.boolean  "admin",                          default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  add_foreign_key "applications", "events"
  add_foreign_key "events", "users", column: "organizer_id"
end
