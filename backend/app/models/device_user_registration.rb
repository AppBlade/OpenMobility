class DeviceUserRegistration < ActiveRecord::Base

  belongs_to :device_registration
  belongs_to :device_user

  def send_push
    device_registration.send_apns_notifications [
      APNS::MdmNotification.new(
        Base64.decode64(apns_token).unpack('H*')[0],
        apns_push_magic
      )
    ]
  end

end
