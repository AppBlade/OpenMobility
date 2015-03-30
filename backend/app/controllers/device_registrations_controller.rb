class DeviceRegistrationsController < ApplicationController

  def create
    @device_registration = DeviceRegistration.create_from_request request
    send_data @device_registration.to_plist(url_for @device_registration), type: :mobileconfig
  end

  def update
    @device_registration = DeviceRegistration.find params[:id]
    @device_registration.update! request
    send_data @device_registration.to_plist(url_for @device_registration), type: :plist
  end

end
