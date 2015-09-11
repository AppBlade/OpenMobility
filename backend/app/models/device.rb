class Device < ActiveRecord::Base

  belongs_to :device_model_firmware, inverse_of: :devices, required: true
  belongs_to :device_variant, inverse_of: :devices

  has_many :device_commands, dependent: :destroy
  has_many :commands, through: :device_commands

  has_many :device_users, dependent: :destroy

  validates :udid, presence: true

  def self.find_or_create_from_challenge_response!(challenge_response)
    device = find_by_udid(challenge_response['UDID']) || new
    device.udid  = challenge_response['UDID']
    device.serial_number = challenge_response['SERIAL']
    device.name  = challenge_response['DEVICE_NAME']
    device.iccid = challenge_response['ICCID']
    device.imei  = challenge_response['IMEI']
    device.meid  = challenge_response['MEID']
    device_model = DeviceModel.where(model: challenge_response['PRODUCT']).first_or_create!
    device_firmware = DeviceFirmware.where(buildid: challenge_response['VERSION']).first_or_create!
    device.device_model_firmware = DeviceModelFirmware.where(device_model_id: device_model, device_firmware_id: device_firmware).first_or_create!
    device.save!
    device
  end

end
