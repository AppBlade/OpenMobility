class CreateDevices < ActiveRecord::Migration
  def change

    create_table :device_models do |t|
      t.string :model, null: false
      t.string :name
      t.string :board_config, :platform
      t.integer :cpid, :bdid
      t.date :release_date
      t.integer :capabilities, null: false, default: 2**Device::Capabilities.count
      t.timestamps null: false
    end
    add_index :device_models, :model, unique: true
    add_index :device_models, :release_date

    create_table :device_firmwares do |t|
      t.string :buildid
      t.integer :major, :minor, :patch
      t.date :release_date
      t.timestamps null: false
    end
    add_index :device_firmwares, :buildid, unique: true
    add_index :device_firmwares, :release_date

    create_table :device_model_firmwares do |t|
      t.integer :device_firmware_id, :device_model_id, null: false
      t.string  :ipsw_url, :ipsw_md5sum, :ipsw_sha1sum
      t.integer :ipsw_size
      t.boolean :signed, default: false, null: false
      t.integer :capabilities, null: false, default: 2**Device::Capabilities.count
      t.date :release_date
      t.timestamps null: false
    end
    add_index :device_model_firmwares, :device_firmware_id
    add_index :device_model_firmwares, :device_model_id
    add_index :device_model_firmwares, [:device_firmware_id, :device_model_id], name: :device_model_firmware, unique: true
    add_index :device_model_firmwares, :release_date

    create_table :device_variants do |t|
      t.string :order_number, null: false
      t.integer :device_model_id, null: false
      t.string :capacity, :color
      t.integer :missing_capabilities, null: false, default: 0
      t.timestamps null: false
    end
    add_index :device_variants, [:order_number, :device_model_id], name: :device_order_model, unique: true
    add_index :device_variants, :device_model_id

    create_table :devices do |t|
      t.string :udid, :serial_number, null: false
      t.string :name, :iccid, :imei
      t.integer :device_model_firmware_id, null: false
      t.integer :device_variant_id
      t.timestamps null: false
    end
    add_index :devices, :device_model_firmware_id
    add_index :devices, :udid

  end
end
