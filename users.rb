require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta accountid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lister ut brukere på konto accountid.")
	exit
end

dst = ARGV[0]
accountid = ARGV[1]
$noOfUsers = 0

canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/accounts/%d/users?per_page=99999", accountid)

def processList(list)
    list.each { |c|
       	printf("%s\t%s\t%s\n", c['id'], c['sis_user_id'], c['name'])
       	$noOfUsers += 1
    } 
end


list = canvas.get(uri)
processList(list)
while list.more?  do
  list = list.next_page!
  processList(list)
  printf("Antall brukere: %d\n", $noOfUsers)
end
printf("Antall brukere: %d\n", $noOfUsers)

