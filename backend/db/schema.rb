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

ActiveRecord::Schema.define(version: 20150330024947) do

  create_table "device_firmwares", force: :cascade do |t|
    t.string   "buildid",      limit: 255
    t.integer  "major",        limit: 4
    t.integer  "minor",        limit: 4
    t.integer  "patch",        limit: 4
    t.date     "release_date"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "device_firmwares", ["buildid"], name: "index_device_firmwares_on_buildid", unique: true, using: :btree
  add_index "device_firmwares", ["release_date"], name: "index_device_firmwares_on_release_date", using: :btree

  create_table "device_model_firmwares", force: :cascade do |t|
    t.integer  "device_firmware_id", limit: 4,                      null: false
    t.integer  "device_model_id",    limit: 4,                      null: false
    t.string   "ipsw_url",           limit: 255
    t.string   "ipsw_md5sum",        limit: 255
    t.string   "ipsw_sha1sum",       limit: 255
    t.integer  "ipsw_size",          limit: 4
    t.boolean  "signed",             limit: 1,   default: false,    null: false
    t.integer  "capabilities",       limit: 4,   default: 16777216, null: false
    t.date     "release_date"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "device_model_firmwares", ["device_firmware_id", "device_model_id"], name: "device_model_firmware", unique: true, using: :btree
  add_index "device_model_firmwares", ["device_firmware_id"], name: "index_device_model_firmwares_on_device_firmware_id", using: :btree
  add_index "device_model_firmwares", ["device_model_id"], name: "index_device_model_firmwares_on_device_model_id", using: :btree
  add_index "device_model_firmwares", ["release_date"], name: "index_device_model_firmwares_on_release_date", using: :btree

  create_table "device_models", force: :cascade do |t|
    t.string   "model",        limit: 255,                    null: false
    t.string   "name",         limit: 255,                    null: false
    t.string   "board_config", limit: 255
    t.string   "platform",     limit: 255
    t.integer  "cpid",         limit: 4
    t.integer  "bdid",         limit: 4
    t.date     "release_date"
    t.integer  "capabilities", limit: 4,   default: 16777216, null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "device_models", ["model"], name: "index_device_models_on_model", unique: true, using: :btree
  add_index "device_models", ["release_date"], name: "index_device_models_on_release_date", using: :btree

  create_table "device_registrations", force: :cascade do |t|
    t.string   "enrollment_challenge_digest", limit: 255,                     null: false
    t.string   "state",                       limit: 255, default: "pending", null: false
    t.integer  "device_id",                   limit: 4
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  create_table "device_variants", force: :cascade do |t|
    t.string   "order_number",         limit: 255,             null: false
    t.integer  "device_model_id",      limit: 4,               null: false
    t.string   "capacity",             limit: 255
    t.string   "color",                limit: 255
    t.integer  "missing_capabilities", limit: 4,   default: 0, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "device_variants", ["device_model_id"], name: "index_device_variants_on_device_model_id", using: :btree
  add_index "device_variants", ["order_number", "device_model_id"], name: "device_order_model", unique: true, using: :btree

  create_table "devices", force: :cascade do |t|
    t.string   "udid",                     limit: 255, null: false
    t.string   "serial_number",            limit: 255, null: false
    t.string   "name",                     limit: 255
    t.string   "iccid",                    limit: 255
    t.string   "imei",                     limit: 255
    t.integer  "device_model_firmware_id", limit: 4,   null: false
    t.integer  "device_variant_id",        limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "devices", ["device_model_firmware_id"], name: "index_devices_on_device_model_firmware_id", using: :btree
  add_index "devices", ["udid"], name: "index_devices_on_udid", using: :btree

end
