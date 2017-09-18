#Forfatter: Erlend Thune (erlend.thune@iktsenteret.no)
#Dato: Høsten 2015
#Skrevet i forbindelse med prosjektet matematikkMOOC
#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection'
require_relative 'siktfunctions'
 
dst = ARGV[0] 
$cid = ARGV[1]

#Kopier bare seksjoner som begynner med denne prefixen.
$sectionPrefix = "Studiegruppe"

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	exit
end

#Opprett Canvasforbindelse. Dette gjøres i connection.rb
$canvas = getCanvasConnection(dst)


#I denne funksjonen kommer det en liste med enrollments fra kurset det skal kopieres fra. Disse legges så inn i seksjonen sectionId i kurset det skal kopieres til.
#Denne seksjonen må eksistere.
def processEnrollments(list)
  list.each { |s| 
  	 if(s["type"] == "StudentViewEnrollment")
#  	 	dbg("Skip because of type #{s['type']}")
	 else
  	 	uid = s["user_id"];
	    limitpermissions = s['limit_privileges_to_course_section']
	    if(limitpermissions == false)
	    	printf("Unlimited: %s #{$host}/courses/%s/users/%s\n", s["user"]["name"],$cid,uid)
	    end
	 end
  }
end

#Her henter man ut alle enrollments i seksjonen spesifisiert i input parameteren.
#Dette vil være en seksjon i kurset det skal kopieres fra. Deretter 
#kaller man processEnrollments helt til det ikke er flere enrollments.
def processSection(section)
	uri = sprintf("/api/v1/sections/%d/enrollments", section["id"])
#	dbg(uri)
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
#		dbg(section["name"])
		if section["name"].start_with?($sectionPrefix) 
			processSection(section)
		end
	}
end

#Hent ut alle seksjonene i kurset det skal kopieres fra. 
#Kurset det skal kopieres fra er spesifisert i en globale variabelen $fromcid som er en ARGV parameter.
uri = sprintf("/api/v1/courses/%d/sections",$cid)
#	dbg(uri)
printf("Course id:%d\n", $cid)
sections = $canvas.get(uri)
processSections(sections)
while sections.more?  do
  sections = sections.next_page!
  processSections(sections)
end

