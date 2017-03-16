require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions'  
$dst = ARGV[0]
cid = ARGV[1]
$frmt = ARGV[2]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid [y]")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut oppgaver i kurs med id cid.")
	dbg("Dersom et tredje argument er oppgitt blir kommandoene skrevet ut på formatet 'ruby submissions.rb prod/beta cid aid' og 'ruby peerreviews.rb prod/beta cid aid'")
	exit
end

$canvas = getCanvasConnection($dst)

def printAssignmentsForCourse(cid)
	list = getAssignments(cid)
	printf("Id\Oppgavenavn\tHverandrevurdering\n")
	list.each { |a|
		if(!a['quiz_id'])	
			if($frmt == nil)
				printf("%s\t%s\t%s\n", a['id'], a['name'], a['peer_reviews'] ? "JA" : "NEI")
			else
				printf("ruby submissions.rb %s %s %d\n", $dst, cid, a['id'])
				if(a['peer_reviews'])
					printf("ruby peerreviews.rb %s %s %d\n", $dst, cid, a['id'])		
				end
			end
		end
	} 
end

printAssignmentsForCourse(cid)


