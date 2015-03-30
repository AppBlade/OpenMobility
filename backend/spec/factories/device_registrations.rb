FactoryGirl.define do

  factory :device_registration_challenged, class: DeviceRegistration do
    state 'challenged'
    enrollment_challenge_digest { BCrypt::Password.create 'challenge_password' }
    created_at { Time.now }
    updated_at { Time.now }
  end

  factory :device_registration_verified, parent: :device_registration_challenged do
    state 'challenge_verified'
    challenge_certificate do

      key = OpenSSL::PKey::RSA.new 2048

      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = 1
      cert.not_before = Time.now
      cert.not_after = Time.now + 1.year

      cert.public_key = key.public_key
      cert.subject = OpenSSL::X509::Name.parse "O=AppBlade/CN=sAppBlade Device Registration/DC=com/DC=appblade"
      cert.issuer = cert.subject
      cert.sign key, OpenSSL::Digest::SHA1.new

      cert.to_pem

    end
    association :device
  end

  factory :device_registration_scep_exchange, parent: :device_registration_verified do
    state 'scep_exchange'
    scep_challenge_digest { BCrypt::Password.create 'digest_password' }
  end

  factory :device_registration_but_not_checkedin, parent: :device_registration_scep_exchange do
    state 'registered'
    device_identity_certificate do

      private_key = OpenSSL::PKey::RSA.new 1024
      public_key = OpenSSL::PKey::RSA.new 1024

      new_cert = OpenSSL::X509::Certificate.new
      new_cert.serial = 1
      new_cert.version = 2
      new_cert.not_before = Time.now
      new_cert.not_after = 3.year.from_now
      new_cert.subject = OpenSSL::X509::Name.parse "O=AppBlade/CN=sAppBlade Device Registration/DC=com/DC=appblade"
      new_cert.public_key = public_key
      new_cert.issuer = ScepCert.subject

      extension_factory = OpenSSL::X509::ExtensionFactory.new
      extension_factory.subject_certificate = new_cert
      extension_factory.issuer_certificate = ScepCert

      new_cert.add_extension extension_factory.create_extension('keyUsage', 'digitalSignature,keyEncipherment')

      new_cert.sign ScepKey, OpenSSL::Digest::SHA1.new
      new_cert.to_pem

    end
  end

  factory :device_registration, parent: :device_registration_but_not_checkedin do
    state 'managed'
    apns_push_magic { SecureRandom.hex }
    apns_token { Base64.encode64 SecureRandom.hex }
  end

end
