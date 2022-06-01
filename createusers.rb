require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 4)
	dbg("Usage: ruby #{$0} prod/beta username_index_start username_index_end accountid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lager nye brukere kompetanse+testbruker<index>@udir.dev med passord testbruker<index> på accountid.")
	exit
end
dst = ARGV[0]
username_index_start = ARGV[1]
username_index_end = ARGV[2]
$accountid = ARGV[3]

$canvas = getCanvasConnection(dst)

def createUser(username) 

	uri = sprintf("/api/v1/accounts/%d/users", $accountid)
	pseudo = username + "@udir.dev"
	newUser = $canvas.post(uri, {'user[name]' => username, 'pseudonym[unique_id]' => pseudo, 'user[terms_of_use]' => 1,'pseudonym[send_confirmation]' => 0 })
	
	print newUser
	
	pw = username
	uri = sprintf("/api/v1/accounts/%d/logins", $accountid)
	newLogin = $canvas.post(uri, {'user[id]' => newUser['id'], 'login[unique_id]' => username, 'login[password]' => pw})
	
	print newLogin
end

x =  username_index_start.to_i
y =  username_index_end.to_i
while x <  y  do
  print  x
  newUserName = "kompetanse+testbruker#{x}"
  createUser(newUserName)
  x = x +1 
end
