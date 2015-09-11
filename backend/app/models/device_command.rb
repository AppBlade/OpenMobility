class DeviceCommand < ActiveRecord::Base

  belongs_to :device
  belongs_to :command
  belongs_to :device_registration
  belongs_to :device_user_registration

  def self.update_and_issue_next_command!(parsed_request, device)
    status = parsed_request['Status']
    if parsed_request['UserID']
      device_user = device.device_users.find_by(user_id: parsed_request['UserID'])
    else
      device_user = nil
    end
    if status != 'Idle'
      device_command = device.device_commands.find(parsed_request['CommandUUID'])
      if status == 'NotNow'
        # set device state to busy
      else
        device_command.update_from_response! parsed_request
      end
    end
    if status == 'NotNow'
      # TODO look up command that are guaranteed
    else
      # TODO don't look up received on guaranteed
      device.device_commands.find_by(
        state: %w(received pending),
        device_user_id: device_user
      )
    end
  end

  def update_from_response!(parsed_request)
    command.parse_response! parsed_request, device
    update(state: parsed_request['Status'].downcase)
  end

  def to_plist
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess({
      CommandUUID: id.to_s,
      Command: command.plist_values
    })
    plist.to_str CFPropertyList::List::FORMAT_XML
  end

end
