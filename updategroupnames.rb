require 'canvas-api'
require 'csv'
require_relative 'connection' 
require_relative 'SiktUtility' 
require_relative 'siktfunctions' 
dst = ARGV[0]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta gid outfile")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lager curlkommandoer i outfile.sh for å endre Skoleleder til Leder i gruppenavn.")
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


def processGroup(group, name)
		 s1 = sprintf("curl '%s/api/v1/groups/%d' ", $host, group["id"]) 
	     s2 = sprintf("-X PUT -F 'name=%s' ", name)
	     s3 = sprintf("-H 'Authorization: Bearer %s'", $token)
	     s4 = sprintf("%s%s%s\n", s1,s2,s3)
	     myputs(s4)
end

def processGroups(groups)
	groups.each { |group| 
        faculty = ""
        gn = group["name"];
        if gn.include? "Skoleleder"
            newName = gn.sub("Skoleleder", "Leder")
            dbg(gn)
            dbg(newName)
            processGroup(group, newName)
        end
    }
end

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



