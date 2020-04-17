#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions' 

dst = ARGV[0]
aid = ARGV[1]


if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta accountid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut brukere i accountid.")
	exit
end

$canvas = getCanvasConnection(dst)
def processUsers(users)
    users.each { |c|
	    printf("%s\t%s\t%s\t%s\t%s\n", c['id'],c['login_id'], c['name'], c['email'], c['sortable_name'])
    }
end

printf("Id\tLoginId\tNavn\t\t\Epost\tSortertbart navn\n")
uri = sprintf("/api/v1/accounts/%d/users",aid)
users = $canvas.get(uri)
processUsers(users)
while users.more?  do
  users = users.next_page!
  processUsers(users)
end
