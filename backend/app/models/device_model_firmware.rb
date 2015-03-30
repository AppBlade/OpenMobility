class DeviceModelFirmware < ActiveRecord::Base

  belongs_to :device_model, inverse_of: :device_model_firmwares, required: true
  belongs_to :device_firmware, inverse_of: :device_model_firmwares, required: true

  has_many :devices

end


