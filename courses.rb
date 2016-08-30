require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta accountid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lister ut kursene på serveren for konto accountid.")
	exit
end

accountid = ARGV[1]

canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/accounts/%d/courses?per_page=999", accountid)


list = canvas.get(uri)
printf("Id\tKursnavn\n")
list.each { |c|
	printf("%s\t%s\n", c['id'], c['name'])
} 


