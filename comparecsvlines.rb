require 'csv'

module MyConfig
  @mac_address_hash = {}
  CSV.foreach("config.csv") do |row|
    name, mac_address = row
    next if name == "Name"
    @mac_address_hash[name] = mac_address
  end

  puts "Now we have this hash: " + @mac_address_hash.inspect

  def self.mac_address(computer_name)
    @mac_address_hash[computer_name]
  end

end

puts "MAC address of Desktop: " + MyConfig.mac_address("Desktop")