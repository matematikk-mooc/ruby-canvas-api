require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta type cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Registrerer brukere rolle lik type på kurs med id cid.")
	dbg("type kan være 'StudentEnrollment', 'TeacherEnrollment','TaEnrollment', 'DesignerEnrollment', 'ObserverEnrollment'.")
	exit
end

dst = ARGV[0]
$etype = ARGV[1]
$cid = ARGV[2]

$canvas = getCanvasConnection(dst)

def enrollUser(id)
{
    uri = sprintf("/api/v1/courses/%d/enrollments", $cid)
    dbg(uri)
    $canvas.post(uri, {'enrollment[user_id]' => id, 'enrollment[type]' => $etype,
        'enrollment[enrollment_state]' => "active"})
end
x =  9
y =  20000
while x <  y  do
  print  x ,". Ruby while loop.\n"
  enrollUser(x)
  x +=1 
end

