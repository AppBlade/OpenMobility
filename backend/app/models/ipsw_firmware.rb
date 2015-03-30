module IpswFirmware

  FIRMWARES_URL = "https://api.ipsw.me/v2.1/firmwares.json".freeze

  NO_DOWNLOAD = {
    'iPod1,1' => [
      {'buildid' => '3A100a', 'version' => '1.1',   'releasedate' => '2007-9-14'},
      {'version' => '2.0',    'buildid' => '5A347', 'releasedate' => '2008-7-11'},
      {'version' => '2.0.1',  'buildid' => '5B108', 'releasedate' => '2008-8-4'},
      {'version' => '2.0.2',  'buildid' => '5C1',   'releasedate' => '2008-8-18'},
      {'version' => '2.1',    'buildid' => '5F137', 'releasedate' => '2008-9-12'},
      {'version' => '2.2',    'buildid' => '5G77',  'releasedate' => '2008-11-21'},
      {'version' => '2.2.1',  'buildid' => '5H11',  'releasedate' => '2009-1-27'},
      {'version' => '3.0',    'buildid' => '7A341', 'releasedate' => '2009-6-17'},
      {'version' => '3.1.1',  'buildid' => '7C145', 'releasedate' => '2009-9-9'},
      {'version' => '3.1.2',  'buildid' => '7D11',  'releasedate' => '2009-10-8'},
      {'version' => '3.3.3',  'buildid' => '7E18',  'releasedate' => '2010-2-2'},
    ],
    'iPod2,1' => [
      {'version' => '3.0',   'buildid' => '7A341', 'releasedate' => '2009-6-17'},
      {'version' => '3.1.1', 'buildid' => '7C145', 'releasedate' => '2009-9-9'},
      {'version' => '3.1.2', 'buildid' => '7D11',  'releasedate' => '2009-10-8'},
      {'version' => '3.1.3', 'buildid' => '7E18',  'releasedate' => '2010-2-2'},
    ],
    'iPhone1,1' => [
      {'buildid' => '1A420', 'version' => '1.0'},
      {'buildid' => '4A57',  'version' => '1.1.3'}
    ],
    'iPhone1,2' => [
      {'buildid' => '5A345', 'version' => '2.0', 'releasedate' => '2008-7-11'}
    ],
    'iPhone3,3' => [
      {'buildid' => '8E128', 'version' => '4.2.5', 'releasedate' => '2011-2-7'}
    ],
    'iPhone5,3' => [
      {'buildid' => '11A466', 'version' => '7.0', 'releasedate' => '2013-9-18'}
    ],
    'iPhone5,4' => [
      {'buildid' => '11A466', 'version' => '7.0', 'releasedate' => '2013-9-18'}
    ],
    'iPhone6,1' => [
      {'buildid' => '11A466', 'version' => '7.0', 'releasedate' => '2013-9-18'}
    ],
    'iPhone6,2' => [
      {'buildid' => '11A466', 'version' => '7.0', 'releasedate' => '2013-9-18'}
    ],
  }

  def self.load_from_ipsw_me!

    response = Faraday.get FIRMWARES_URL

    if response.success?

      parsed_response = JSON.parse response.body
      parsed_response['devices'].each do |model, device_attributes|

        device_model = DeviceModel.find_by_model model
        device_model ||= DeviceModel.new
        
        capabilities = Entitlements.each_with_index.map do |capability, index|
          if model.start_with?(*capability[:families_missing])
            0
          else
            2 ** (index + 1)
          end
        end.inject { |sum, element| sum + element }
        
        device_model.attributes = {
          model: model, 
          name: device_attributes['name'],
          board_config: device_attributes['BoardConfig'],
          platform: device_attributes['platform'],
          cpid: device_attributes['cpid'],
          bdid: device_attributes['bdid'],
          capabilities: capabilities
        }

        device_model.save!
        
        (device_attributes['firmwares'] + NO_DOWNLOAD.fetch(model, [])).each do |firmware_attributes|
          
          major, minor, patch = firmware_attributes['version'].split('.')
          patch ||= 0
          
          device_firmware = DeviceFirmware.find_by_buildid firmware_attributes['buildid']
          device_firmware ||= DeviceFirmware.create(buildid: firmware_attributes['buildid'], major: major, minor: minor, patch: patch)
          
          device_model_firmware = DeviceModelFirmware.where(device_firmware_id: device_firmware, device_model_id: device_model).first
          device_model_firmware ||= DeviceModelFirmware.new

          release_date = firmware_attributes['releasedate'] || firmware_attributes['uploaddate']
          release_date = Date.parse release_date if release_date
          
          capabilities = Entitlements.each_with_index.map do |capability, index|
            if model.start_with?(*capability[:families_missing]) || (([major, minor] <=> capability[:required_os]) == -1)
              0
            else
              2 ** (index + 1)
            end
          end.inject { |sum, element| sum + element }
          
          device_model_firmware.attributes = {
            device_firmware: device_firmware, 
            device_model: device_model,
            ipsw_url: firmware_attributes['url'],
            release_date: release_date,
            ipsw_size: firmware_attributes['size'],
            ipsw_md5sum: firmware_attributes['md5sum'],
            ipsw_sha1sum: firmware_attributes['sha1sum'],
            signed: !!firmware_attributes['signed'],
            capabilities: capabilities
          }

          device_model_firmware.save!
          
        end
      end
      
      # Populate release dates, these are approximate
      DeviceModel.find_each do |device_model|
        device_model.update!(
          release_date: device_model.device_model_firmwares.map(&:release_date).compact.min
        )
      end
      DeviceFirmware.find_each do |device_firmware|
        device_firmware.update!(
          release_date: device_firmware.device_model_firmwares.map(&:release_date).compact.min
        )
      end

    end

  end
end
