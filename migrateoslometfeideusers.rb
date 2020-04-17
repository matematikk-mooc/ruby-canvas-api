require 'csv'
require 'canvas-api'
require 'colorize'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta aid userfile")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Legger ny login til brukerne i userfile. Sjekk kode for hvordan dette gjøres.")
	exit
end

dst = ARGV[0]
account_id = ARGV[1]
userfile = ARGV[2]

$canvas = getCanvasConnection(dst)

puts "User file: " + userfile
users = CSV.open(userfile, headers: :first_row).map(&:to_h)
users.each { |x| 
    currentLoginId = x["login_id"]
    newLoginId = currentLoginId.gsub(/@.*/, "@oslomet.no")
    puts x["login_id"] + "->" + newLoginId
    addLoginToUser(account_id, x["id"], newLoginId)
}

