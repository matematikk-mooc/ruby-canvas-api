require 'canvas-api'
require 'csv'
require_relative 'connection' 
require_relative 'SiktUtility' 
require_relative 'siktfunctions' 
dst = ARGV[0]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta gid outfile")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lager curlkommandoer i outfile.sh for å legge på faculty: på fakultetsgrupper.")
	dbg("Gjelder gruppekategori med id lik gid.")
	dbg("Fikk ikke PUT til å fungere med whitmer sitt API. Derfor måtte jeg gå via curl.")
	dbg("Husk å kjære chmod +x på .sh filen før du kjører den, og ta gjerne en kikk inni den for å se at ting ser greit ut.")
	exit
end

gid = ARGV[1]
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


def processGroup(group, faculty)
#		 /api/v1/groups/:group_id
#curl https://<canvas>/api/v1/groups/<group_id> \
#     -X PUT \
#     -F 'name=Algebra Teachers' \
#     -F 'join_level=parent_context_request' \
#     -H 'Authorization: Bearer MRZCOUiX9Iars4IKPoYDVblWERT9rvGSh8ZW4re54RjfiOlG0VZcE07JRsn8eiHx'
		 fixed_string = "faculty:" + faculty + ":" + group["description"]
		 s1 = sprintf("curl '%s/api/v1/groups/%d' ", $host, group["id"]) 
	     s2 = sprintf("-X PUT -F 'description=%s' ", fixed_string)
	     s3 = sprintf("-H 'Authorization: Bearer %s'", $token)
	     s4 = sprintf("%s%s%s\n", s1,s2,s3)
	     myputs(s4)
end

#I denne funksjonen løper man gjennom alle seksjonene i listen som kommer inn og prosesserer hver av dem.
def processGroups(groups)
	groups.each { |group| 
        faculty = ""
        gn = group["name"];
        gd = group["description"]
        if !gd.include? "faculty"
            if gn.include? "Matematikk 1-7"
                faculty = "matematikk17"
            elsif gn.include? "Matematikk 8-10"
                faculty = "matematikk810"
            elsif gn.include? "Naturfag 1-7"
                faculty = "naturfag17"
            elsif gn.include? "Naturfag 8-10"
                faculty = "naturfag810"
            elsif gn.include? "Kunst"
                faculty = "kunsthndverk110"
            elsif gn.include? "Musikk"
                faculty = "musikk110"
            end
            if(faculty != "")
                dbg(group["name"])
                processGroup(group, faculty)
            end
        end
    }
end

#Hent ut alle seksjonene i kurset det skal kopieres fra. 
#Kurset det skal kopieres fra er spesifisert i en globale variabelen $cid som er en ARGV parameter.

OpenFile(outfile + ".sh")
myputs("#!/bin/sh\n")
uri = sprintf("/api/v1/group_categories/%d/groups?per_page=999",gid)
dbg(uri)
groups = $canvas.get(uri)
processGroups(groups)
while groups.more?  do
  groups = groups.next_page!
  processGroups(groups)
end

CloseFile()



