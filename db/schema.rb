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

ActiveRecord::Schema.define(version: 20180528142416) do

  create_table "schedules", force: :cascade do |t|
    t.string "title"
    t.integer "talk_room_type_id"
    t.string "talk_room_id"
    t.string "schedule_type"
    t.date "post_date"
    t.string "post_day"
    t.integer "post_hour"
    t.integer "post_minute"
    t.string "create_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "talk_room_types", force: :cascade do |t|
    t.string "type_name"
    t.string "target_id_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
