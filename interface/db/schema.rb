# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_08_08_184110) do
  create_table "cities", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.bigint "region_id", null: false
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_cities_on_country_id"
    t.index ["region_id"], name: "index_cities_on_region_id"
  end

  create_table "collections", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "img_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.string "img_link"
    t.string "alt_names"
    t.bigint "city_id", null: false
    t.bigint "region_id", null: false
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_locations_on_city_id"
    t.index ["country_id"], name: "index_locations_on_country_id"
    t.index ["region_id"], name: "index_locations_on_region_id"
  end

  create_table "months", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.integer "number"
    t.bigint "year_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year_id"], name: "index_months_on_year_id"
  end

  create_table "previews", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.integer "sorting_number"
    t.string "description"
    t.string "img_link"
    t.bigint "collection_id", null: false
    t.bigint "location_id", null: false
    t.bigint "city_id", null: false
    t.bigint "region_id", null: false
    t.bigint "country_id", null: false
    t.bigint "stamp_id", null: false
    t.bigint "month_id", null: false
    t.bigint "year_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_previews_on_city_id"
    t.index ["collection_id"], name: "index_previews_on_collection_id"
    t.index ["country_id"], name: "index_previews_on_country_id"
    t.index ["location_id"], name: "index_previews_on_location_id"
    t.index ["month_id"], name: "index_previews_on_month_id"
    t.index ["region_id"], name: "index_previews_on_region_id"
    t.index ["stamp_id"], name: "index_previews_on_stamp_id"
    t.index ["year_id"], name: "index_previews_on_year_id"
  end

  create_table "regions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_regions_on_country_id"
  end

  create_table "stamps", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.bigint "month_id", null: false
    t.bigint "year_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["month_id"], name: "index_stamps_on_month_id"
    t.index ["year_id"], name: "index_stamps_on_year_id"
  end

  create_table "years", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "cities", "countries"
  add_foreign_key "cities", "regions"
  add_foreign_key "locations", "cities"
  add_foreign_key "locations", "countries"
  add_foreign_key "locations", "regions"
  add_foreign_key "months", "years"
  add_foreign_key "previews", "cities"
  add_foreign_key "previews", "collections"
  add_foreign_key "previews", "countries"
  add_foreign_key "previews", "locations"
  add_foreign_key "previews", "months"
  add_foreign_key "previews", "regions"
  add_foreign_key "previews", "stamps"
  add_foreign_key "previews", "years"
  add_foreign_key "regions", "countries"
  add_foreign_key "stamps", "months"
  add_foreign_key "stamps", "years"
end
