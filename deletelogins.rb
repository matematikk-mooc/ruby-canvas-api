require 'csv'
require 'canvas-api'
require 'colorize'
require 'json'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 4)
	dbg("Usage: ruby #{$0} prod/beta account_id loginsfile authentication_provider_id")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
    dbg("Logins i loginsfile med authentication_provider_id blir slettet.")
    dbg("Dersom login id er den eneste som er tilknyttet brukeren vil brukeren bli slettet fra account_id.")
	exit
end

dst = ARGV[0]
account_id = ARGV[1]
loginsfile = ARGV[2]
authentication_provider_id = ARGV[3]

$canvas = getCanvasConnection(dst)


puts "Logins file: " + loginsfile
users = CSV.open(loginsfile, headers: :first_row).map(&:to_h)

users.each { |user|
    if(authentication_provider_id == user["authentication_provider_id"])
        begin
            puts "Delete #{user["unique_id"]} #{user["user_id"]} #{user["id"]}"
            result = deleteLogin(user["user_id"], user["id"])
            puts result
        rescue => error
#            puts (error.message)
            a = eval(error.message)
            b = a["base"]
#            puts b[0]["message"]
            c = b[0]["message"]
            if(c == "Brukere må ha minst én logg inn")
                deleteUser(user["user_id"], account_id)
            else 
                puts error.message
            end
        end
    end
}


