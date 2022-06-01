require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta accountid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Generer kpas index.html for kursene på serveren for konto accountid.")
	exit
end

dst = ARGV[0]
$accountId = ARGV[1]

$canvas = getCanvasConnection(dst)

def OpenFile(filename)
	$file = File.open( filename,"w" )
end

def CloseFile()
	$file.close
end

def myputs(s)
	$file << s
end

def processCourses(list)
    list.each { |c|
        puts(c["name"])
        puts(c["account_id"])
        puts $accountId
        if(c["account_id"].to_i == $accountId.to_i)
            puts("MATCH")
            s = sprintf("<li><a href='https://kompetanseudirno.azureedge.net/udirdesign/kpas/brukere.html?courseId=%d'>%s</a></li>\n",c['id'],c['name'])
            myputs(s);
        end
    } 
end

OpenFile("index.html")
myputs('<!DOCTYPE html>
<html lang="no">
<head>
    <meta charset="utf-8" name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
<h1>Brukerstatistikk kompetanse.udir.no</h1>
Klikk deg inn på kompetansepakkene for å se hvor mange som har vært aktive i kompetansepakken.
Statistikken oppdateres hver natt.
<ul>
')


list = getCourses($accountId)
processCourses(list)
while list.more?  do
  list = list.next_page!
  processCourses(list)
end
myputs('</ul></body></html>')
CloseFile()