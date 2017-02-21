require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 5)
	dbg("Usage: ruby #{$0} prod/beta user_type user_id type cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Registrerer bruker med user_id som deltager med rolle lik type på kurs med id cid.")
	dbg("Dersom user_type er sis skal user_id tilsvare sis_user_id.")
	dbg("type kan være 'StudentEnrollment', 'TeacherEnrollment','TaEnrollment', 'DesignerEnrollment', 'ObserverEnrollment'.")
	exit
end

dst = ARGV[0]
user_type = ARGV[1]
user_id = ARGV[2]
etype = ARGV[3]
cid = ARGV[4]

$canvas = getCanvasConnection(dst)

if(user_type == "sis")
	u = getUserFromSisUserId(user_id)
	user_id = u["id"]
end

uri = sprintf("/api/v1/courses/%d/enrollments", cid)
dbg(uri)
$canvas.post(uri, {'enrollment[user_id]' => user_id, 'enrollment[type]' => etype,
	'enrollment[enrollment_state]' => "active"})


