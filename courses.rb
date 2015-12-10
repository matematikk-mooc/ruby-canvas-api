require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]

if(ARGV.size < 1)
	dbg("Usage: ruby #{$0} prod/beta")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lister ut kursene på serveren.")
	exit
end

canvas = getCanvasConnection(dst)


uri = "/api/v1/accounts/1/courses"
list = canvas.get(uri)
printf("Id\tKursnavn\n")
list.each { |c|
	printf("%s\t%s\n", c['id'], c['name'])
} 


