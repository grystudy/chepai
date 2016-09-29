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

ActiveRecord::Schema.define(version: 20160927090458) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "che_pais", force: :cascade do |t|
    t.integer  "source_id"
    t.string   "chepai"
    t.string   "fadongji"
    t.string   "chejia"
    t.string   "x"
    t.integer  "city_code"
    t.string   "city_name"
    t.integer  "provience_code"
    t.string   "provience_name"
    t.datetime "time"
    t.datetime "time1"
    t.integer  "plate_number_id"
    t.integer  "ftf"
    t.index ["plate_number_id"], name: "index_che_pais_on_plate_number_id", using: :btree
  end

  create_table "plate_numbers", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_plate_numbers_on_name", using: :btree
  end

  create_table "uu_che_pais", force: :cascade do |t|
    t.string  "chepai"
    t.string  "fadongji"
    t.string  "chejia"
    t.integer "plate_number_id"
    t.integer "ftf"
    t.index ["plate_number_id"], name: "index_uu_che_pais_on_plate_number_id", using: :btree
  end

  create_table "weizhang_items", force: :cascade do |t|
    t.text "info"
  end

  create_table "weizhang_items_queries", id: false, force: :cascade do |t|
    t.integer "weizhang_item_id",  null: false
    t.integer "weizhang_query_id", null: false
  end

  create_table "weizhang_queries", force: :cascade do |t|
    t.integer  "plate_number_id"
    t.datetime "time"
    t.index ["plate_number_id"], name: "index_weizhang_queries_on_plate_number_id", using: :btree
  end

  add_foreign_key "che_pais", "plate_numbers"
  add_foreign_key "uu_che_pais", "plate_numbers"
  add_foreign_key "weizhang_queries", "plate_numbers"
end
