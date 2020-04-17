require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]
cid = ARGV[1]
sectionname = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid sectionname")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lager en ny seksjon i emnet cid med navn sectionname.")
	exit
end


canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/courses/%d/sections", cid)
print uri
newSection = canvas.post(uri, {'course_section[name]' => sectionname})

print newSection

