#Forfatter: Erlend Thune (erlend.thune@iktsenteret.no)
#Dato: Høsten 2015
#Skrevet i forbindelse med prosjektet matematikkMOOC
#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection'
require_relative 'siktfunctions'
 
dst = ARGV[0] 
$fromcid = ARGV[1]
$tocid = ARGV[2]
$permissions = ARGV[3]

#Kopier bare seksjoner som begynner med denne prefixen.
$sectionPrefix = "Studiegruppe"

if(ARGV.size < 4)
	dbg("Usage: ruby #{$0} prod/beta from_cid to_cid begrens")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen kopierer seksjoner fra kurset med kurs id from_cid til kurset med kurs id to_cid.")
	dbg("Bare seksjoner som begynner med prefixet #{$sectionPrefix} blir kopiert.")
	dbg("Dette prefixet kan settes i .rb filen")
	dbg("Vær oppmerksom på at en ny seksjon med samme navn blir opprettet dersom den finnes fra før.")
	dbg("Dersom 'begrens' er satt til 'section' eller 'public' blir brukernes rettigheter satt til dette.")
	dbg("Dersom 'begrens' er satt til 'samme' blir brukernes rettigheter satt til den samme som det ")
	dbg("brukeren har i seksjonen man kopierer fra.")
	exit
end

#Opprett Canvasforbindelse. Dette gjøres i connection.rb
$canvas = getCanvasConnection(dst)


#I denne funksjonen kommer det en liste med enrollments fra kurset det skal kopieres fra. Disse legges så inn i seksjonen sectionId i kurset det skal kopieres til.
#Denne seksjonen må eksistere.
def processEnrollments(list, sectionId)
  uri = sprintf("/api/v1/sections/%d/enrollments", sectionId)
  list.each { |s| 
  	 #Skip test user
  	 if(s["type"] == "StudentViewEnrollment")
  	 	dbg("Skip because of type #{s['type']}")
	 else
  	 	uid = s["user_id"];
	    dbg("Add user #{uid} to #{sectionId}")
	    dbg(s)
	    limitpermissions = s['limit_privileges_to_course_section']
	    if($permissions == "section")
	    	limitpermissions = true
	    elsif($permissions == "public")
	    	limitpermissions = false
	    end
		dbg("Set permission to ")
		dbg(limitpermissions)	    
	    $canvas.post(uri, {'enrollment[user_id]' => uid, 
	    'enrollment[type]' => s["type"], 
	    'enrollment[enrollment_state]' => 'active', 
	    'enrollment[course_section_id]' => sectionId,
	    'enrollment[limit_privileges_to_course_section]' => limitpermissions })
  	 end
  }
end

#Her opprettes det en seksjon i kurset det skal kopieres til. Seksjonen bruker samme navn som i input parameteren section.
#Kurset det skal kopieres til er spesifisert i den globale variabelen $tocid som er en ARGV parameter.
def createSection(section)
  uri = sprintf("/api/v1/courses/%d/sections/", $tocid) 
  
  dbg("POST #{uri}")
  dbg("course_section[name]=#{section["name"]}")
  newSection = $canvas.post(uri, {'course_section[name]' => section["name"]})
  dbg(newSection)
  return newSection
end

#Her henter man ut alle enrollments i seksjonen spesifisiert i input parameteren.
#Dette vil være en seksjon i kurset det skal kopieres fra. Deretter 
#kaller man processEnrollments helt til det ikke er flere enrollments.
def processSection(section)
	toSection = createSection(section)
	uri = sprintf("/api/v1/sections/%d/enrollments", section["id"])
	list = $canvas.get(uri)
	processEnrollments(list, toSection["id"])
	while list.more?  do
	  list = list.next_page!
	  processEnrollments(list, toSection["id"])
	end
end

#I denne funksjonen løper man gjennom alle seksjonene i listen som kommer inn og prosesserer hver av dem.
def processSections(sections)
	sections.each { |section| 
		dbg(section["name"])
		if section["name"].start_with?($sectionPrefix) 
			processSection(section)
		end
	}
end

#Hent ut alle seksjonene i kurset det skal kopieres fra. 
#Kurset det skal kopieres fra er spesifisert i en globale variabelen $fromcid som er en ARGV parameter.
uri = sprintf("/api/v1/courses/%d/sections",$fromcid)
sections = $canvas.get(uri)
processSections(sections)
while sections.more?  do
  sections = sections.next_page!
  processSections(sections)
end

