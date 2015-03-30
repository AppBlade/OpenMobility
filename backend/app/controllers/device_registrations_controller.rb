class DeviceRegistrationsController < ApplicationController

  def create
    @device_registration = DeviceRegistration.create_from_request request
    send_data @device_registration.to_plist(url_for @device_registration), status: :created, type: :mobileconfig
  end

  def update
    @device_registration = DeviceRegistration.find params[:id]
    @device_registration.update! request
    registration_url = device_registration_url(@device_registration, protocol: 'https')
    send_data @device_registration.to_plist(registration_url), type: :plist
  end

end
