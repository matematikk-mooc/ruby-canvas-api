require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta accountid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lister ut underkontoene for accountid på serveren.")
	exit
end

accountid = ARGV[1]

canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/accounts/%d/sub_accounts?per_page=999", accountid)


list = canvas.get(uri)
printf("Id\Underkonto\n")
list.each { |c|
	printf("%s\t%s\n", c['id'], c['name'])
} 


