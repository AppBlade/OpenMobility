class DeviceDetails < ActiveRecord::Migration
  def change
    add_column :devices, :meid, :string
    add_column :devices, :phone_number, :string
    add_column :devices, :subscriber_carrier, :string
    add_column :devices, :sim_carrier, :string
    add_column :devices, :wifi_mac_address, :string
    add_column :devices, :last_cloud_backup_at, :datetime
    add_column :devices, :supervised, :boolean
    add_column :devices, :roaming, :boolean
    add_column :devices, :do_not_disturb, :boolean
    add_column :devices, :device_locator_service_enabled, :boolean
    add_column :devices, :cloud_backup_enabled, :boolean
    add_column :devices, :activation_lock_enabled, :boolean
    add_column :devices, :eas_identifier, :string
    add_column :devices, :roaming_enabled, :boolean
    add_column :devices, :bluetooth_mac_address, :string
    add_column :devices, :battery_level, :float
    add_column :devices, :remaining_storage_capacity, :float
    add_column :devices, :storage_capacity, :float
    add_column :devices, :last_checkin_at, :datetime
  end
end
