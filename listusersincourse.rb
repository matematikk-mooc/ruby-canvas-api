#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions' 

dst = ARGV[0]
cid = ARGV[1]
outfile = ARGV[2]


if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid filename")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut bruker id, epost, fullt navn, navn som skal vises og navn for sortering for alle seksjoner for kurs med kurs id 'cid'.")
	exit
end

dbg("Outfile:")
dbg(outfile)

$canvas = getCanvasConnection(dst)


$canvas = getCanvasConnection(dst)
$file = nil

def OpenFile(filename)
	$file = File.open( filename,"w" )
end

def CloseFile()
	$file.close
end

def myputs(s)
	$file << s
end



def processEnrollments(list)
  list.each { |s| 
	 uid = s["user_id"];
     p = getUserProfile(uid)
	 s = sprintf("%s\t%s\t%s\t%s\n", p['id'], p['login_id'], p['primary_email'], p['name'], p['short_name'], p['sortable_name'])
	 myputs(s)
  }
end

#Her henter man ut alle enrollments i seksjonen spesifisiert i input parameteren.
#Dette vil være en seksjon i kurset det skal kopieres fra. Deretter 
#kaller man processEnrollments helt til det ikke er flere enrollments.
def processSection(section)
    myputs("\n");
    myputs(section["name"]);
    myputs("\n");
	uri = sprintf("/api/v1/sections/%d/enrollments", section["id"])
	list = $canvas.get(uri)
	processEnrollments(list)
	while list.more?  do
	  list = list.next_page!
	  processEnrollments(list)
	end
end

#I denne funksjonen løper man gjennom alle seksjonene i listen som kommer inn og prosesserer hver av dem.
def processSections(sections)
	sections.each { |section| 
		processSection(section)
	}
end

OpenFile(outfile)
myputs("Id\tLogin Id\tPrimary email\tFullt navn\tNavn som skal vises\tNavn for sortering\n")

uri = sprintf("/api/v1/courses/%d/sections",cid)
sections = $canvas.get(uri)
processSections(sections)
while sections.more?  do
  sections = sections.next_page!
  processSections(sections)
end

CloseFile()
