require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions'
dst = ARGV[0]

canvas = getCanvasConnection(dst)

sis_user_id = ARGV[1]
status = ARGV[2]
if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta sis_user_id status")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen oppdaterer alle enrollments for bruker med sis_user_id til status.")
    dbg("Status kan være enten conclude, delete, inactivate, deactivate")
	exit
end

uri = sprintf("/api/v1/users/sis_user_id:%s/enrollments?per_page=999", sis_user_id)
list = canvas.get(uri)
list.each { |e|
    deleteuri = sprintf("/api/v1/courses/%d/enrollments/%d?task=%s", e["course_id"],e["id"], status)
    dbg(deleteuri)
    result = canvas.delete(deleteuri)
    print result
} 


