require 'canvas-api'
require 'csv'
require_relative 'connection' 
require_relative 'SiktUtility' 
require_relative 'siktfunctions' 
dst = ARGV[0]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid outfile")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lager curlkommandoer i outfile for å sette seksjonsnavnet i parenteser etter brukernavnet.")
	dbg("Fikk ikke PUT til å fungere med whitmer sitt API. Derfor måtte jeg gå via curl.")
	exit
end

cid = ARGV[1]
outfile = ARGV[2]

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

def getUserProfile(sid)
    uri = sprintf("/api/v1/users/%d/profile",sid)
    profile = $canvas.get(uri)
    return profile
end

#I denne funksjonen kommer det en liste med enrollments fra kurset det skal kopieres fra. Disse legges så inn i seksjonen sectionId i kurset det skal kopieres til.
#Denne seksjonen må eksistere.
#curl 'https://beta.matematikk.mooc.no/api/v1/users/900.json' \
#     -X PUT \
#     -F 'user[name]=Sheldon Cooper' \
#     -H "Authorization: Bearer MRZCOUiX9Iars4IKPoYDVblWERT9rvGSh8ZW4re54RjfiOlG0VZcE07JRsn8eiHx"
def processEnrollments(list, sectionName)
  list.each { |s| 
		 uid = s["user_id"];
		 u = getUserProfile(uid)
		 
		 newname = u["name"]

		 s1 = sprintf("curl '%s/api/v1/users/%d.json' ", $host, uid) 
	     s2 = sprintf("-X PUT ")
	     s3 = sprintf("-F 'user[short_name]=%s' ", newname)
	     s4 = sprintf("-F 'user[sortable_name]=%s' ", newname)
	     s5 = sprintf("-H 'Authorization: Bearer %s'", $token)
	     s6 = sprintf("%s%s%s%s%s\n", s1,s2,s3,s4,s5)
	     puts s6
	     myputs(s6)
  }
end

#Her henter man ut alle enrollments i seksjonen spesifisiert i input parameteren.
#Dette vil være en seksjon i kurset det skal kopieres fra. Deretter 
#kaller man processEnrollments helt til det ikke er flere enrollments.
def processSection(section)
	uri = sprintf("/api/v1/sections/%d/enrollments", section["id"])
	list = $canvas.get(uri)
	processEnrollments(list, section["name"])
	while list.more?  do
	  list = list.next_page!
	  processEnrollments(list, section["name"])
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

OpenFile(outfile)
myputs("#!/bin/sh\n")
uri = sprintf("/api/v1/courses/%d/sections",cid)
dbg(uri)
sections = $canvas.get(uri)
processSections(sections)
while sections.more?  do
  sections = sections.next_page!
  processSections(sections)
end

CloseFile()



