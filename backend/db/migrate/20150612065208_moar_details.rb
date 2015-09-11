class MoarDetails < ActiveRecord::Migration
  def change
    add_column :devices, :itunes_store_account_hash, :string
    add_column :devices, :itunes_store_account_active, :boolean
    add_column :devices, :personal_hotspot_enabled, :boolean
    add_column :devices, :subscriber_mcc, :integer
    add_column :devices, :subscriber_mnc, :integer
    add_column :devices, :current_mcc, :integer
    add_column :devices, :current_mnc, :integer
    add_column :devices, :passcode_compliant, :boolean
    add_column :devices, :passcode_compliant_with_profiles, :boolean
    add_column :devices, :passcode_present, :boolean
    add_column :devices, :block_level_encryption_enabled, :boolean
    add_column :devices, :file_level_encryption_enabled, :boolean
    add_column :devices, :full_disk_encryption_enabled, :boolean
    add_column :devices, :full_disk_encryption_has_personal_recovery_key, :boolean
    add_column :devices, :full_disk_encryption_has_institutional_recovery_key, :boolean
  end
end
