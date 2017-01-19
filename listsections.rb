#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions' 

dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut seksjoner for kurs med kurs id 'cid'.")
	exit
end

canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/courses/%d/sections",cid)
list = canvas.get(uri)
printf("Id\Section name\n")
list.each { |c|
	printf("%s\t%s\n", c['id'], c['name'])
} 

