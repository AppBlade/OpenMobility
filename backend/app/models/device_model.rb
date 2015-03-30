class DeviceModel < ActiveRecord::Base

  has_many :device_model_firmwares, dependent: :destroy
  has_many :device_firmwares, through: :device_model_firmwares

  has_many :device_variants, dependent: :destroy

end

