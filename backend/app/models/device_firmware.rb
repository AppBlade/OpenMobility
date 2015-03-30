class DeviceFirmware < ActiveRecord::Base

  has_many :device_model_firmwares, dependent: :destroy
  has_many :device_models, through: :device_model_firmwares

end

