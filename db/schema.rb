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

ActiveRecord::Schema[8.1].define(version: 2026_07_05_201713) do
  create_table "devices", force: :cascade do |t|
    t.boolean "brightness"
    t.string "category"
    t.boolean "color"
    t.datetime "created_at", null: false
    t.string "ip"
    t.string "local_key"
    t.string "name"
    t.boolean "on_off"
    t.string "protocol_version"
    t.string "tuya_device_id"
    t.datetime "updated_at", null: false
  end
end
