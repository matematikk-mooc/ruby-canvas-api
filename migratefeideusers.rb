require 'csv'
require 'canvas-api'
require 'colorize'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta aid userfile migratefile")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Migrerer feidebrukere ved å legge til en ny login id fra migratefile for brukerne i userfile på konto med id aid.")
	exit
end

dst = ARGV[0]
accountid = ARGV[1]
userfile = ARGV[2]
migratefile = ARGV[3]

$canvas = getCanvasConnection(dst)

account_id = 1

puts "Migrate file: " + migratefile
mapping = CSV.read(migratefile, {:col_sep => ";"})
#config.each { |x| 
#    puts x[0]
#    puts x[1]
# }

puts "User file: " + userfile
users = CSV.open(userfile, headers: :first_row).map(&:to_h)
#puts users[0]["login_id"]
#users.each { |x| 
#    puts x["login_id"]
#}

mapping.each { |x|
    user = users.find {|y| y["login_id"] == x[0]}
    if(user)
        puts user
        puts "Adding login " + x[1]
        begin
            addLoginToUser(account_id, user["id"], x[1])
        rescue
            msg = "addLoginToUser failed for id " + user["id"] + " user name " + user["name"] + " login id " + x[1]
            puts msg.red
        end
    else
        msg = "Brukeren " + x[0] + " eksisterer ikke"
        puts msg.red
    end
}


