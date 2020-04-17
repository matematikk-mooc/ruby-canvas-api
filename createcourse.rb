require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]
aid = ARGV[1]
coursename = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta aid coursename")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lager et nytt kurs i konto aid med navn coursename.")
	exit
end


canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/accounts/%d/courses", aid)
print uri
newCourse = canvas.post(uri, {'course[name]' => coursename})

print newCourse

