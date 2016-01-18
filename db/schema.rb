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

ActiveRecord::Schema.define(version: 20151226115116) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "event_id"
    t.text     "attendee_info_1"
    t.text     "attendee_info_2"
  end

  add_index "applications", ["event_id"], name: "index_applications_on_event_id", using: :btree

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
  end

  add_foreign_key "applications", "events"
end
