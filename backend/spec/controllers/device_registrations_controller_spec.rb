require 'rails_helper'

RSpec.describe DeviceRegistrationsController, type: :controller do

  # create should generate a new device registration and return a JSON response
  # following the mobileconfig link from the JSON response should do the expected thing
     # have a challenge & enrollment path
  # should handle a signed iPhone payload

  context "should have the expected challenge workflow" do

    let(:initial_create) { post :create }

    # TODO break this up more
    it 'handles the registration request flow' do
      expect(initial_create).to have_http_status(:created)

      # Parse the server response
      plist = CFPropertyList::List.new(data: initial_create.body)
      parsed_plist = CFPropertyList.native_types plist.value
      enrollment_url = parsed_plist['PayloadContent']['URL']
      challenge = parsed_plist['PayloadContent']['Challenge']

      expect(enrollment_url).to_not be nil

      # Build a stubbed device
      device = build_stubbed(:device)

      # Response with expected params
      response = CFPropertyList::List.new
      response.value = CFPropertyList.guess({
        'CHALLENGE' => challenge,
        'UDID' => device.udid,
        'SERIAL' => device.serial_number,
        'PRODUCT' => device.device_model_firmware.device_model.model,
        'VERSION' => device.device_model_firmware.device_firmware.buildid
      })

      # Pretend to sign it
		  signed_response = OpenSSL::PKCS7::sign AppleIPhoneDeviceCA,
        AppleiPhoneDeviceKey,
        response.to_str(CFPropertyList::List::FORMAT_XML),
        [AppleIPhoneDeviceCA],
        OpenSSL::PKCS7::BINARY

      # Trigger phase 2
      registration_id = enrollment_url.split('/').last
      challenge_response = put :update, {
        id: registration_id,
        file: signed_response.to_der
      }

      expect(challenge_response).to have_http_status(:ok)

      # Parse the response, look for the p12
      plist = CFPropertyList::List.new(data: challenge_response.body)
      parsed_plist = CFPropertyList.native_types plist.value

      passphrase = parsed_plist['PayloadContent'][0]['Password']
      payload_content = parsed_plist['PayloadContent'][0]['PayloadContent']

      p12 = OpenSSL::PKCS12.new payload_content, passphrase

      # Send back the expected result, signed against the p12
      response = CFPropertyList::List.new
      response.value = CFPropertyList.guess({
        'UDID' => device.udid,
        'SERIAL' => device.serial_number,
        'PRODUCT' => device.device_model_firmware.device_model.model,
        'VERSION' => device.device_model_firmware.device_firmware.buildid
      })

		  signed_response = OpenSSL::PKCS7::sign p12.certificate,
        p12.key,
        response.to_str(CFPropertyList::List::FORMAT_XML),
        [p12.certificate],
        OpenSSL::PKCS7::BINARY

      # Check that we get a SCEP / MDM response back
      verification_response = put :update, {
        id: registration_id,
        file: signed_response.to_der
      }
      expect(verification_response).to have_http_status(:ok)
      plist = CFPropertyList::List.new(data: verification_response.body)
      parsed_plist = CFPropertyList.native_types plist.value

      expect(parsed_plist['PayloadContent'][0]['PayloadContent']['URL']).to eql(
        "https://test.host/device_registrations/#{registration_id}/certificates"
      )
      expect(parsed_plist['PayloadContent'][1]['CheckInURL']).to eql(
        "https://test.host/device_registrations/#{registration_id}"
      )
      expect(parsed_plist['PayloadContent'][1]['ServerURL']).to eql(
        "https://test.host/device_registrations/#{registration_id}/queue"
      )

    end

  end

end
