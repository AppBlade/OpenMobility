# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


IpswFirmware.load_from_ipsw_me!

request = Faraday.get "http://theiphonewiki.com/wiki/Models"
doc = Nokogiri::HTML request.body

MissingEntitlements = {
  'auto-focus-camera' => %(ME643),
  'still-camera' => %(ME643),
  'video-camera' => %w(ME643),
  'camera-flash' => %w(ME643),
}.freeze

[
  TableParser::Table.new(doc, '//table[@class="wikitable"][1]'),
  TableParser::Table.new(doc, '//table[@class="wikitable"][2]'),
  TableParser::Table.new(doc, '//table[@class="wikitable"][3]'),
  TableParser::Table.new(doc, '//table[@class="wikitable"][4]'),
  TableParser::Table.new(doc, '//table[@class="wikitable"][5]'),
].each do |table|
  (1...table.columns.first.size).each do |row|
    table.columns[table.columns.size-1].children[row].text.scan(/[A-Z0-9]+/).each do |order_number|
      
      model = table.columns[table.columns.size-4].children[row].text.strip
      color = table.columns[table.columns.size-3].children[row].text.strip
      capacity = table.columns[table.columns.size-2].children[row].text.strip

      missing_capabilities = Entitlements.each_with_index.map do |capability, index|
        if MissingEntitlements.fetch(capability[:entitlement], []).include? order_number
          2 ** (index + 1)
        else
          0
        end
      end.inject { |sum, element| sum + element }

      device_model = DeviceModel.find_by_model model
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
