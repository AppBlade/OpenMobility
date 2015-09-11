class Command < ActiveRecord::Base

  has_many :device_commands, dependent: :destroy
  has_many :devices, through: :device_commands

  serialize :settings, Hash

  def plist_values
    {RequestType: type.gsub(/Command$/, '')}
  end

  def parse_response!(response, device)
  end

end

class DeviceInformationCommand < Command

  GeneralQueries = %w(UDID Languages Locales DeviceID OrganizationInfo LastCloudBackupDate).freeze
  DeviceInformationQueries = %w(DeviceName OSVersion BuildVersion ModelName Model ProductName SerialNumber DeviceCapacity AvailableDeviceCapacity BatteryLevel CellularTechnology IMEI MEID ModemFirmwareVersion IsSupervised IsDeviceLocatorServiceEnabled IsActivationLockEnabled IsDoNotDisturbInEffect DeviceID EASDeviceIdentifier IsCloudBackupEnabled).freeze
  NetworkInformationQueries = %w(ICCID BluetoothMAC WiFiMAC EthernetMACs CurrentCarrierNetwork SIMCarrierNetwork SubscriberCarrierNetwork CarrierSettingsVersion PhoneNumber VoiceRoamingEnabled DataRoamingEnabled IsRoaming PersonalHotspotEnabled SubscriberMCC SubscriberMNC CurrentMCC CurrentMNC).freeze
  ItunesStoreAccountQueries = %w(iTunesStoreAccountIsActive iTunesStoreAccountHash)

  def plist_values
    super.merge({
      Queries: GeneralQueries | DeviceInformationQueries | NetworkInformationQueries | ItunesStoreAccountQueries
    })
  end

  def parse_response!(response, device)
    response = response['QueryResponses']
    device_model = DeviceModel.find_or_create_by(model: response['ProductName'])
    major, minor, patch = response['OSVersion'].split('.')
    patch ||= 0
    device_firmware = DeviceFirmware.find_or_create_by(buildid: response['BuildVersion'], major: major, minor: minor, patch: patch)
    device_model_firmware = DeviceModelFirmware.find_or_create_by(device_firmware: device_firmware, device_model: device_model)
    device.update(
      name: response['DeviceName'],
      imei: response['IMEI'],
      iccid: response['ICCID'],
      meid: response['MEID'],
      phone_number: response['PhoneNumber'],
      subscriber_carrier: response['SubscriberCarrierNetwork'],
      sim_carrier: response['SIMCarrierNetwork'],
      wifi_mac_address: response['WiFiMAC'],
      last_cloud_backup_at: response['LastCloudBackupDate'],
      supervised: response['IsSupervised'],
      roaming: response['IsRoaming'],
      do_not_disturb: response['IsDoNotDisturbInEffect'],
      device_locator_service_enabled: response['IsDeviceLocatorServiceEnabled'],
      cloud_backup_enabled: response['IsCloudBackupEnabled'],
      activation_lock_enabled: response['IsActivationLockEnabled'],
      eas_identifier: response['EASDeviceIdentifier'],
      roaming_enabled: response['DataRoamingEnabled'],
      bluetooth_mac_address: response['BluetoothMAC'],
      battery_level: response['BatteryLevel'],
      remaining_storage_capacity: response['AvailableDeviceCapacity'],
      storage_capacity: response['DeviceCapacity'],
      device_model_firmware: device_model_firmware,
      last_checkin_at: Time.now,
      itunes_store_account_hash: response['iTunesStoreAccountHash'],
      itunes_store_account_active: response['iTunesStoreAccountIsActive'],
      personal_hotspot_enabled: response['PersonalHotspotEnabled'],
      subscriber_mcc: response['SubscriberMCC'],
      subscriber_mnc: response['SubscriberMNC'],
      current_mcc: response['CurrentMCC'],
      current_mnc: response['CurrentMNC']
    )
  end

end

class SecurityInfoCommand < Command

  def parse_response!(response, device)
    response = response['SecurityInfo']
    device.update(
      passcode_compliant: response['PasscodeCompliant'],
      passcode_compliant_with_profiles: response['PasscodeCompliantWithProfiles'],
      passcode_present: response['PasscodePresent'],
      block_level_encryption_enabled: response['HardwareEncryptionCaps'] && response['HardwareEncryptionCaps'] & 1 == 1,
      file_level_encryption_enabled: response['HardwareEncryptionCaps'] && response['HardwareEncryptionCaps'] & 2 == 2,
      full_disk_encryption_enabled: response['FDE_Enabled'],
      full_disk_encryption_has_personal_recovery_key: response['FDE_HasPersonalRecoveryKey'],
      full_disk_encryption_has_institutional_recovery_key: response['FDE_HasInstitutionalRecoveryKey']
    )
  end

end
