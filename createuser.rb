require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]
username = ARGV[1]
accountid = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta username accountid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lager en ny bruker username@erlendthune.com med passord usernameusername på accountid.")
	exit
end


canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/accounts/%d/users", accountid)
#pseudo = username + "@erlendthune.com"
pseudo = username

newUser = canvas.post(uri, {'user[name]' => username, 'pseudonym[unique_id]' => pseudo, 'user[terms_of_use]' => 1,'pseudonym[send_confirmation]' => 0 })

print newUser

pw = username + username
uri = sprintf("/api/v1/accounts/%d/logins", accountid)
newLogin = canvas.post(uri, {'user[id]' => newUser['id'], 'login[unique_id]' => username, 'login[password]' => pw})

print newLogin
