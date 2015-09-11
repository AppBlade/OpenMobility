class DeviceUser < ActiveRecord::Base

  belongs_to :device

  has_many :device_user_registrations, dependent: :destroy
  has_many :device_registrations, through: :device_user_registrations

end
