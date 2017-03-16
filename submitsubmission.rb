require 'canvas-api'
require 'csv'
require_relative 'connection' 
require_relative 'SiktUtility' 
require_relative 'siktfunctions' 
dst = ARGV[0] 
$cid = ARGV[1]
$aid = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid aid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen leverer en innlevering for alle studenter i kurs cid oppgave aid.")
	exit
end

dbg(ARGV.size)
$canvas = getCanvasConnection(dst)

#I denne funksjonen kommer det en liste med enrollments fra kurset det skal kopieres fra. Disse legges så inn i seksjonen sectionId i kurset det skal kopieres til.
#Denne seksjonen må eksistere.
def submitSubmission(id)
	 s = sprintf("Dette er bruker id %d sin innlevering", id)
	 puts(s)
	 uri = sprintf("/api/v1/courses/%d/assignments/%d/submissions?as_user_id=%d", $cid, $aid, id);
	 puts(uri)
	 $canvas.post(uri, 
	 {
	 	'submission[submission_type]' => 'online_text_entry', 
	    'submission[body]' => s
	 })
end

def processStudents(list)
  list.each { |s| 
	 id = s["id"]
	 submitSubmission(id)
  }
end


#Hent ut alle seksjonene i kurset det skal kopieres fra. 
#Kurset det skal kopieres fra er spesifisert i en globale variabelen $cid som er en ARGV parameter.

uri = sprintf("/api/v1/courses/%d/students?per_page=999",$cid)
dbg(uri)
students = $canvas.get(uri)
processStudents(students)

