require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions'  
dst = ARGV[0]
accountid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta account_id")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut oppgaver i alle kurs for konto med id account_id.")
	exit
end

$canvas = getCanvasConnection(dst)

def printAssignmentsForCourse(cid, coursename)
	list = getAssignments(cid)
	list.each { |a|
		if(!a['quiz_id'])	
			printf("%s\t%s\t%s\t%s\t%s\n", a['id'], a['name'], a['peer_reviews'] ? "JA" : "NEI", cid, coursename)
		end
	} 
end

def processCourses(list)
    list.each { |c|
    	printAssignmentsForCourse(c['id'], c['name'])
    } 
end

printf("Oppgave Id\tOppgavenavn\tHverandrevurdering\tKurs Id\tKursnavn\n")
uri = sprintf("/api/v1/accounts/%d/courses?per_page=999", accountid)

list = $canvas.get(uri)
processCourses(list)
while list.more?  do
  list = list.next_page!
  processCourses(list)
end