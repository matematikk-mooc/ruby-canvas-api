require 'canvas-api'
require 'csv'
require_relative 'connection' 
require_relative 'SiktUtility' 
require_relative 'siktfunctions' 
dst = ARGV[0] 
$cid = ARGV[1]
$gid = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid gid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen oppretter 6000 grupper basert på seksjoner for kurset med id 'cid'.")
	dbg("Gruppene legges i gruppesettet med id 'gid' og medlemmene er studentene i de tilhørende seksjonene.")
	dbg("Seksjonene må eksistere og være på formatet '#{SiktUtility.sectionPrefix} nn'.")
	dbg("Gruppesettet må eksistere. Gruppene får navn på formatet '#{SiktUtility.groupPrefix} nn'.")
	dbg("nn er det som knytter seksjonen og gruppen sammen.")
	exit
end

dbg(ARGV.size)
$canvas = getCanvasConnection(dst)

#I denne funksjonen kommer det en liste med enrollments fra kurset det skal kopieres fra. Disse legges så inn i seksjonen sectionId i kurset det skal kopieres til.
#Denne seksjonen må eksistere.
def processEnrollments(list, groupId)
  list.each { |s| 
	 enrollmentType = s["type"]
	 dbg("Enrollment type #{enrollmentType}")
     if enrollmentType == "StudentEnrollment"
		 uid = s["user_id"];
		 dbg("Add user #{uid} to #{groupId}")
		 addUserToGroup(uid, groupId)
	 end
  }
end

#Her henter man ut alle enrollments i seksjonen spesifisiert i input parameteren.
#Dette vil være en seksjon i kurset det skal kopieres fra. Deretter 
#kaller man processEnrollments helt til det ikke er flere enrollments.
def processSection(section)
	sectionNo = section['name'][-2,2]
	sectionNoWithoutWhiteSpace = sectionNo.gsub(/\s+/, '')
	gn = sprintf("%s %s", SiktUtility.groupPrefix, sectionNoWithoutWhiteSpace)
	dbg("Lag gruppen #{gn}")
	group = createGroup(gn, $gid)
	uri = sprintf("/api/v1/sections/%d/enrollments", section["id"])
	list = $canvas.get(uri)
	processEnrollments(list, group["id"])
	while list.more?  do
	  list = list.next_page!
	  processEnrollments(list, group["id"])
	end
end

#I denne funksjonen løper man gjennom alle seksjonene i listen som kommer inn og prosesserer hver av dem.
def processSections(sections)
	sections.each { |section| 
		dbg(section["name"])
		if section["name"].start_with?(SiktUtility.sectionPrefix) 
			processSection(section)
		end
	}
end

#Hent ut alle seksjonene i kurset det skal kopieres fra. 
#Kurset det skal kopieres fra er spesifisert i en globale variabelen $cid som er en ARGV parameter.

uri = sprintf("/api/v1/courses/%d/sections",$cid)
dbg(uri)
sections = $canvas.get(uri)
processSections(sections)
while sections.more?  do
  sections = sections.next_page!
  processSections(sections)
end

