require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions'
dst = ARGV[0]

canvas = getCanvasConnection(dst)

cid = ARGV[1]
frmt = ARGV[2]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut modulene i kurset 'cid'.")
	dbg("Dersom et tredje valgfritt argument er oppgitt blir kommandoene skrevet ut på formatet 'ruby statistikk.rb prod/beta cid mid'")
	dbg("Dette kan så limes inn i et shell script for å generere statistikk for gjennomføringen av modulene i et kurs.")
	dbg("Se statistikk.rb for nærmere informasjon.")
	exit
end

uri = sprintf("/api/v1/courses/%d/modules", cid)
list = canvas.get(uri)
printf("Id\tModulnavn\n")
list.each { |m|
	if(frmt == nil)
		printf("%s\t%s\n", m['id'], m['name'])
	else	
		printf("ruby statistikk.rb %s %d %d\n", dst, cid, m['id'])
	end
} 


