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

ActiveRecord::Schema.define(version: 20150612065208) do

  create_table "commands", force: :cascade do |t|
    t.string   "type",                 limit: 255
    t.text     "settings",             limit: 65535
    t.integer  "dependent_command_id", limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "commands", ["id", "type"], name: "notnow_queue", using: :btree

  create_table "device_commands", force: :cascade do |t|
    t.integer  "device_id",              limit: 4,                       null: false
    t.integer  "command_id",             limit: 4,                       null: false
    t.integer  "device_registration_id", limit: 4
    t.string   "state",                  limit: 255, default: "pending", null: false
    t.datetime "received_at"
    t.integer  "device_user_id",         limit: 4
  end

  add_index "device_commands", ["device_id", "state"], name: "queue", using: :btree
  add_index "device_commands", ["id", "device_id"], name: "log_status", using: :btree

  create_table "device_firmwares", force: :cascade do |t|
    t.string   "buildid",      limit: 255
    t.integer  "major",        limit: 4
    t.integer  "minor",        limit: 4
    t.integer  "patch",        limit: 4
    t.date     "release_date"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "beta",         limit: 255
  end

  add_index "device_firmwares", ["buildid"], name: "index_device_firmwares_on_buildid", using: :btree
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
    t.string   "name",         limit: 255, default: ""
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
    t.string   "enrollment_challenge_digest", limit: 255,                          null: false
    t.string   "state",                       limit: 255,   default: "challenged", null: false
    t.integer  "device_id",                   limit: 4
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.string   "user_agent",                  limit: 255
    t.text     "challenge_certificate",       limit: 65535
    t.string   "scep_challenge_digest",       limit: 255
    t.text     "device_identity_certificate", limit: 65535
    t.string   "apns_push_magic",             limit: 255
    t.string   "apns_token",                  limit: 255
  end

  create_table "device_user_registrations", force: :cascade do |t|
    t.string  "apns_token",             limit: 255
    t.string  "apns_push_magic",        limit: 255
    t.integer "device_user_id",         limit: 4,   null: false
    t.integer "device_registration_id", limit: 4,   null: false
  end

  add_index "device_user_registrations", ["device_registration_id"], name: "index_device_user_registrations_on_device_registration_id", using: :btree
  add_index "device_user_registrations", ["device_user_id", "device_registration_id"], name: "uniqueness", unique: true, using: :btree
  add_index "device_user_registrations", ["device_user_id"], name: "index_device_user_registrations_on_device_user_id", using: :btree

  create_table "device_users", force: :cascade do |t|
    t.string   "user_id",         limit: 255
    t.string   "user_long_name",  limit: 255
    t.string   "user_short_name", limit: 255
    t.integer  "device_id",       limit: 4,   null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "device_users", ["device_id", "user_id"], name: "index_device_users_on_device_id_and_user_id", unique: true, using: :btree
  add_index "device_users", ["device_id"], name: "index_device_users_on_device_id", using: :btree

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
    t.string   "udid",                                                limit: 255, null: false
    t.string   "serial_number",                                       limit: 255, null: false
    t.string   "name",                                                limit: 255
    t.string   "iccid",                                               limit: 255
    t.string   "imei",                                                limit: 255
    t.integer  "device_model_firmware_id",                            limit: 4,   null: false
    t.integer  "device_variant_id",                                   limit: 4
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.string   "meid",                                                limit: 255
    t.string   "phone_number",                                        limit: 255
    t.string   "subscriber_carrier",                                  limit: 255
    t.string   "sim_carrier",                                         limit: 255
    t.string   "wifi_mac_address",                                    limit: 255
    t.datetime "last_cloud_backup_at"
    t.boolean  "supervised",                                          limit: 1
    t.boolean  "roaming",                                             limit: 1
    t.boolean  "do_not_disturb",                                      limit: 1
    t.boolean  "device_locator_service_enabled",                      limit: 1
    t.boolean  "cloud_backup_enabled",                                limit: 1
    t.boolean  "activation_lock_enabled",                             limit: 1
    t.string   "eas_identifier",                                      limit: 255
    t.boolean  "roaming_enabled",                                     limit: 1
    t.string   "bluetooth_mac_address",                               limit: 255
    t.float    "battery_level",                                       limit: 24
    t.float    "remaining_storage_capacity",                          limit: 24
    t.float    "storage_capacity",                                    limit: 24
    t.datetime "last_checkin_at"
    t.string   "itunes_store_account_hash",                           limit: 255
    t.boolean  "itunes_store_account_active",                         limit: 1
    t.boolean  "personal_hotspot_enabled",                            limit: 1
    t.integer  "subscriber_mcc",                                      limit: 4
    t.integer  "subscriber_mnc",                                      limit: 4
    t.integer  "current_mcc",                                         limit: 4
    t.integer  "current_mnc",                                         limit: 4
    t.boolean  "passcode_compliant",                                  limit: 1
    t.boolean  "passcode_compliant_with_profiles",                    limit: 1
    t.boolean  "passcode_present",                                    limit: 1
    t.boolean  "block_level_encryption_enabled",                      limit: 1
    t.boolean  "file_level_encryption_enabled",                       limit: 1
    t.boolean  "full_disk_encryption_enabled",                        limit: 1
    t.boolean  "full_disk_encryption_has_personal_recovery_key",      limit: 1
    t.boolean  "full_disk_encryption_has_institutional_recovery_key", limit: 1
  end

  add_index "devices", ["device_model_firmware_id"], name: "index_devices_on_device_model_firmware_id", using: :btree
  add_index "devices", ["udid"], name: "index_devices_on_udid", using: :btree

end
