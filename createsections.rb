require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid sectionname")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lager nye seksjoner i emnet cid.")
	exit
end


canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/courses/%d/sections", cid)
print uri

n=0
while n < 6000
  n += 1
  sectionname = sprintf("Studiegruppe %d", n)
  puts sectionname
  newSection = canvas.post(uri, {'course_section[name]' => sectionname})
  puts newSection
end

