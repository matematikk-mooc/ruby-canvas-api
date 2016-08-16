require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]

if(ARGV.size < 1)
	dbg("Usage: ruby #{$0} prod/beta")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lister ut kontoene på serveren.")
	exit
end


canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/accounts")


list = canvas.get(uri)
printf("Id\Konto\n")
list.each { |c|
	printf("%s\t%s\n", c['id'], c['name'])
} 


