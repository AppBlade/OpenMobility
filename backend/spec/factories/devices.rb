FactoryGirl.define do
  factory :device do
    udid          { SecureRandom.uuid.gsub(/-/, '') }
    serial_number { SecureRandom.hex(6).upcase }
    name          { SecureRandom.hex(6) }
    device_model_firmware { DeviceModelFirmware.all.sample }
  end
end

