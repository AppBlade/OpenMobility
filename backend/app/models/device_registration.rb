class DeviceRegistration < ActiveRecord::Base

  include BCrypt

  belongs_to :device

  AccessRights = %i(configuration_profile_inspection configuration_profile_management device_lock_and_unlock device_erase device_information_queries network_information_queries provisioning_profile_inspection provisioning_profile_management application_inspection restriction_queries security_queries setting_management application_management).freeze

  def self.create_from_request(request)
    create do |device_registration|
      device_registration.user_agent = request.env['HTTP_USER_AGENT']
      device_registration.enrollment_challenge = SecureRandom.hex 32
    end
  end

  def enrollment_challenge
    @enrollment_challenge ||= Password.new enrollment_challenge_digest
  end

  def enrollment_challenge=(new_enrollment_challenge)
    @enrollment_challenge = new_enrollment_challenge
    self.enrollment_challenge_digest = Password.create @enrollment_challenge
  end

  def scep_challenge
    @scep_challenge ||= Password.new scep_challenge_digest
  end

  def scep_challenge=(new_scep_challenge)
    @scep_challenge = new_scep_challenge
    self.scep_challenge_digest = Password.create @scep_challenge
  end

  def to_plist(payload_url)
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess plist_values(payload_url)
    plist.to_str CFPropertyList::List::FORMAT_XML
  end

  def access_rights
    AccessRights.each_with_index.map do |right, index|
      if true
        (1 + index) ** 2
      else
        0
      end
    end.inject { |lor, element| lor | element }
	end

  def plist_values(payload_url)
    case state
    when 'challenged'
      {
        'PayloadContent' => {
          'URL' => payload_url,
          'DeviceAttributes' => %w(UDID IMEI ICCID MEID SERIAL MAC_ADDRESS_EN0 VERSION PRODUCT DEVICE_NAME),
          'Challenge' => enrollment_challenge
        },
        'PayloadOrganization' => 'AppBlade',
        'PayloadDisplayName' => 'asdf',
        'PayloadVersion' => 1,
        'PayloadUUID' => SecureRandom.uuid,
        'PayloadIdentifier' => 'com.appblade.mobileconfig.profile-service',
        'PayloadDescription' => 'asdf',
        'PayloadType' => 'Profile Service'
      }
    when 'verified'
      {
        'PayloadContent' => [{
          'Password' => @passphrase,
          'PayloadCertificateFileName' => @uuid,
          'PayloadContent' => StringIO.new(@p12.to_der),
          'PayloadDescription' => 'asf',
          'PayloadDisplayName' => 'asdf',
          'PayloadIdentifier' => "com.appblade.phase-2.credentials",
          'PayloadOrganization' => 'AppBlade',
          'PayloadType' => 'com.apple.security.pkcs12',
          'PayloadUUID' => @uuid,
          'PayloadVersion' => 1
        }],
        'PayloadOrganization' => 'AppBlade',
        'PayloadDisplayName' => 'asdf',
        'PayloadVersion' => 1,
        'PayloadUUID' => SecureRandom.uuid,
        'PayloadIdentifier' => "com.appblade.phase-2",
        'PayloadDescription' => 'asdf',
        'PayloadType' => 'Configuration'
      }
    when 'scep_exchange'
      {
        'PayloadContent' => [{
          'PayloadContent' => {
            'Key Type' => 'RSA',
            'Key Usage' => 5,
            'Keysize' => 1024,
            'Challenge' => scep_challenge,
            'Subject' => [[
              ['CN', 'AppBlade Registration']
            ]],
            'URL' => "#{payload_url}/certificates"
          },
          'PayloadOrganization' => 'AppBlade',
          'PayloadDisplayName' => 'asdf',
          'PayloadVersion' => 1,
          'PayloadUUID' => @uuid,
          'PayloadIdentifier' => 'com.appblade.registration.scep',
          'PayloadDescription' => 'asdf',
          'PayloadType' => 'com.apple.security.scep'
        },{
          'AccessRights' => access_rights,
          'CheckInURL' => payload_url,
          'CheckOutWhenRemoved' => true,
          'IdentityCertificateUUID' => @uuid,
          'PayloadDescription' => 'asdfadsf',
          'PayloadDisplayName' => 'asdfdasf',
          'PayloadIdentifier' => 'com.appblade.registration.mdm',
          'PayloadOrganization' => 'AppBlade',
          'PayloadType' => 'com.apple.mdm',
          'PayloadUUID' => SecureRandom.uuid,
          'PayloadVersion' => 1,
          'ServerURL' => "#{payload_url}/queue",
          'SignMessage' => true,
          'Topic' => ApnsTopic,
          'ServerCapabilities' => %w(com.apple.mdm.per-user-connections)
        }],
        'PayloadOrganization' => 'AppBlade',
        'PayloadDisplayName' => 'asdf',
        'PayloadVersion' => 1,
        'PayloadUUID' => SecureRandom.uuid,
        'PayloadIdentifier' => 'com.appblade.registration',
        'PayloadDescription' => 'asdf',
        'PayloadType' => 'Configuration'
      }
    end
  end

  # TODO mark all other device registrations as unenrolled
  # TODO handle local users on OSX
  def update_from_check_in!(parsed_request)
    case parsed_request['MessageType']
    when 'TokenUpdate'
      self.apns_push_magic = parsed_request['PushMagic']
      self.apns_token = Base64.encode64 parsed_request['Token']
      save!
    when 'Authenticate'
      self.state = 'managed'
      transaction do
        # TODO test failure
        # TODO add index?
        device_registrations = DeviceRegistration.arel_table
        DeviceRegistration.where(
          device_registrations[:device_id].eq(device_id).and(
            device_registrations[:id].not_eq(id)
          )
        ).destroy_all
        save!
      end
    when 'CheckOut'
      destroy
    end
  end

  def update!(request)
    body = request.params[:file] || request.body.read
    response = OpenSSL::PKCS7.new(body)
    response.verify(nil, OpenSSL::X509::Store.new, nil, OpenSSL::PKCS7::NOVERIFY)
    plist = CFPropertyList::List.new(data: response.data)
    plist_data = CFPropertyList.native_types(plist.value)

    # Reset the state machine on retry
    # TODO test retry
    self.state = 'challenged' if plist_data['CHALLENGE']

    case state
    when 'challenged'
      raise ArgumentError unless enrollment_challenge == plist_data['CHALLENGE']

      #raise ArgumentError unless response.verify [AppleIPhoneDeviceCA], AppleDeviceX509Store

      # generate and give a challenge certificate
      # TODO put this into a helper and share with the factory
      key = OpenSSL::PKey::RSA.new 2048

      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = id
      cert.not_before = Time.now
      cert.not_after = Time.now + 1.year

      cert.public_key = key.public_key
      cert.subject = OpenSSL::X509::Name.parse "O=AppBlade/CN=sAppBlade Device Registration/DC=com/DC=appblade"
      cert.issuer = cert.subject
      cert.sign key, OpenSSL::Digest::SHA1.new

      @uuid = SecureRandom.uuid
      @passphrase = SecureRandom.hex 32
      @p12 = OpenSSL::PKCS12.create @passphrase, @uuid, key, cert

      self.challenge_certificate = cert.to_pem
      self.state = 'verified'

      # TODO test this transaction
      Device.transaction do
        self.device = Device.find_or_create_from_challenge_response! plist_data
        save!
      end

    when 'verified'

      challenge_certificate = OpenSSL::X509::Certificate.new self.challenge_certificate

      store = OpenSSL::X509::Store.new
      store.add_cert challenge_certificate
      raise ArgumentError unless response.verify [challenge_certificate], store

      self.scep_challenge = SecureRandom.hex 32
      self.state = 'scep_exchange'

      @uuid = SecureRandom.uuid

      save!
    end
    self
  end

end
