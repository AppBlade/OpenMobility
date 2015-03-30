class DeviceVariant < ActiveRecord::Base

  belongs_to :device_model, inverse_of: :device_variants, required: true
  
  has_many :devices

end
