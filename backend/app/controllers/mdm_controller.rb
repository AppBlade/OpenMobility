class MdmController < ApplicationController

  def queue
    fail PermissionDenied unless device_udid_matches? && valid_mdm_signature?
    pending_command = DeviceCommand.update_and_issue_next_command! parsed_response, device
    send_data pending_command.try(&:to_plist), type: :xml
  end

  def check_in
    fail PermissionDenied unless device_udid_matches? && valid_mdm_signature?
    Rails.logger.info parsed_request
    device_registration.update_from_check_in! parsed_request
    head :ok
  end

private

  def device_registration
    @device_registration ||= DeviceRegistration.includes(:device).find params[:id]
  end

  def device
    device_registration.device
  end

  def device_udid_matches?
    parsed_request['UDID'] == device.udid
  end

  def valid_mdm_signature?
    store = OpenSSL::X509::Store.new
    store.add_cert ScepCert
    envelope = OpenSSL::PKCS7.new mdm_signature
    envelope.verify [device_identity_certificate], store, body, OpenSSL::PKCS7::DETACHED
  end

  def device_identity_certificate
    @device_identity_certificate ||= OpenSSL::X509::Certificate.new device_registration.device_identity_certificate
  end

  def body
    @body ||= request.body.read
  end

  def parsed_request
    @parsed_request ||= begin
      plist = CFPropertyList::List.new(data: body)
      CFPropertyList.native_types plist.value
    end
  end

  def mdm_signature
    Base64.decode64 request.headers['HTTP_MDM_SIGNATURE']
  end

end
