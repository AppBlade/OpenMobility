# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


IpswFirmware.load_from_ipsw_me!

connection = Faraday.new "https://www.theiphonewiki.com", ssl: {verify: false}
request = connection.get "/wiki/Models"
doc = Nokogiri::HTML request.body

MissingEntitlements = {
  'auto-focus-camera' => %(ME643),
  'still-camera' => %(ME643),
  'video-camera' => %w(ME643),
  'camera-flash' => %w(ME643),
}.freeze

doc.xpath('//table[@class="wikitable"]').each_with_index do |_, index|

  table = TableParser::Table.new doc, "//table[@class=\"wikitable\"][#{index + 1}]"

  table_headers = table.columns.map do |column|
    column.element.children.text.strip
  end

  (1...table.columns.first.size).each do |row|

    table.columns[table.columns.size-1].children[row].text.scan(/[A-Z0-9]+/).each do |order_number|

      model = table.columns[table_headers.index('Identifier')].children[row].text.strip
      color = table.columns[table_headers.index('Color')].children[row].text.strip
      capacity = table.columns[table_headers.index('Storage')].children[row].text.strip
      name = table.columns[table_headers.index('Generation')].children[row].text.strip
      board_config = table.columns[table_headers.index('Internal Name')].children[row].text.strip

      missing_capabilities = Entitlements.each_with_index.map do |capability, index|
        if MissingEntitlements.fetch(capability[:entitlement], []).include? order_number
          2 ** (index + 1)
        else
          0
        end
      end.inject { |sum, element| sum + element }

      device_model = DeviceModel.find_by_model model
      device_model ||= DeviceModel.new(
        model: model,
        name: name,
        board_config: board_config
      )
      device_variant = device_model.device_variants.find_by_order_number order_number
      device_variant ||= device_model.device_variants.new
      device_variant.attributes = {
        order_number: order_number,
        capacity: capacity,
        color: color,
        missing_capabilities: missing_capabilities
      }
      device_variant.save!
    end

  end

end

request = connection.get "/wiki/Beta_Firmware"
doc = Nokogiri::HTML request.body

doc.xpath('//table[@class="wikitable"]').each_with_index do |_, index|

  header = doc.xpath("//table[@class=\"wikitable\"][#{index + 1}]/preceding-sibling::*[1]")
  board_config = header.children.first.children.first.attributes['href'].to_s.split('/').last.downcase
  board_config = 'n78ap' if board_config == 'ipod_touch_5g'

  table = TableParser::Table.new doc, "//table[@class=\"wikitable\"][#{index + 1}]"

  table_headers = table.columns.map do |column|
    column.element.children.text.strip
  end

  (1...table.columns.first.size).each do |row|

    buildid = table.columns[table_headers.rindex('Build')].children[row].text.strip
    next if buildid == '?'
    major, minor, patch, beta  = table.columns[table_headers.index('Version')].children[row].text.strip.scan(/^(\d+)\.(\d+)\.?(\d+)?(.+)?/).first
    beta = 'b1' if beta == 'b'
    patch ||= 0
    release_date = table.columns[table_headers.rindex('Release Date')].children[row].text.strip
    parsed_release_date = Date.parse(release_date) rescue nil

    device_firmware = DeviceFirmware.where(
      buildid: buildid,
      major: major, minor: minor, patch: patch, beta: beta
    ).first
    device_firmware ||= DeviceFirmware.create(
      buildid: buildid,
      major: major, minor: minor, patch: patch, beta: beta,
      release_date: parsed_release_date
    )

    device_model = DeviceModel.find_by_board_config board_config
    device_model_firmware = DeviceModelFirmware.where(device_firmware_id: device_firmware.id, device_model_id: device_model.id).first
    device_model_firmware ||= DeviceModelFirmware.create(
      device_firmware_id: device_firmware.id,
      device_model_id: device_model.id,
      release_date: parsed_release_date
    )

  end

end
