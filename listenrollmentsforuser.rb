require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions'
dst = ARGV[0]

canvas = getCanvasConnection(dst)

sis_user_id = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta sis_user_id")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister alle enrollments for bruker med sis_user_id.")
	exit
end

uri = sprintf("/api/v1/users/sis_user_id:%s/enrollments?per_page=999", sis_user_id)
list = canvas.get(uri)
printf("Kurs id\tStatus\n")
list.each { |e|
    printf("%d\t%s\n", e["course_id"], e["enrollment_state"])
} 


