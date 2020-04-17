require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions'
dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen printer ut gruppesett for kurs med kurs id 'cid'.")
	exit
end

canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/courses/%d/group_categories", cid)
print uri
list = canvas.get(uri)
printf("Id\tGruppekategori\n")
list.each { |c|
	printf("%s\t%s\n", c['id'], c['name'])
} 


