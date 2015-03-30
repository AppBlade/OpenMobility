class DeviceCommand < ActiveRecord::Base

  belongs_to :device
  belongs_to :command

  def self.update_and_issue_next_command!(parsed_response, device)
    status = parsed_response['Status']
    if status != 'Idle'
      device_command = device.device_commands.find(parsed_response['CommmandUUID'])
      if status != 'NotNow'
        # set device state to busy
      else
        device_command.update_from_response! parsed_response
      end
    end
    nil
  end

  def update_from_response!(parsed_response)
  end

  def to_plist
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess plist_values
    plist.to_str CFPropertyList::List::FORMAT_XML
  end

  def plist_values
    {
      'CommandUUID' => id,
      'Command' => {
        'RequestType' => type
      }
    }
  end

end
