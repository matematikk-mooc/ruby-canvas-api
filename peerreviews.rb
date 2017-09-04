#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
require_relative 'SiktUtility' 

dst = ARGV[0]
#course id
$cid = ARGV[1]

#assignment id
$aid = ARGV[2]


if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid aid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen skriver ut status på oppgave aid i kurs cid.")
	exit
end

$canvas = getCanvasConnection(dst)

$file = nil
$shfile = nil

def dbg(s)
	STDERR.puts s
end

def OpenFile(filename)
	$file = File.open( filename,"w" )
end

def CloseFile()
	$file.close
end

def myputs(s)
	$file << s
end

def printHeading()
    myputs("<tr><th>Bruker</th><th>Hverandrevurderer</th><th>Kommentarer</th></tr>")
end


$notdone = Array.new
$notreceived = Array.new

def getSubmission(cid, aid, uid)
	uri = sprintf("/api/v1/courses/%d/assignments/%d/submissions/%d?include[]=rubric_assessment&per_page=1000", cid,aid,uid)
	return $canvas.get(uri)
end

def processReviews(list)
  list.each { |s| 
  	    uid = s["user"]["id"]
  		userSectionNo = SiktUtility.sectionUserHash[uid]
  		userName = getUserName(s["user"])
  		dbg("user: #{userName} id:#{uid} Seksjon:#{userSectionNo}")
  		dbg(userName)
  		dbg(s["assessor"])
  		aid = s["assessor"]["id"]
  		assessorName = getAssessorName(s["assessor"])
  		assessorSectionNo = SiktUtility.sectionUserHash[aid]
  		dbg("assessorName: #{assessorName} id:#{aid} Seksjon:#{assessorSectionNo}")
  		comments = getComments(s["submission_comments"])
  		
  		subm = getSubmission($cid, $aid, uid)
	  	rubric_comments = getRubricComments(subm["rubric_assessment"])


	    assessorstr = sprintf("%s (Seksjon %s)", assessorName, assessorSectionNo)
  	    userstr = sprintf("%s (Seksjon %s)", userName, userSectionNo)

  		if(s["workflow_state"]!="completed")
  			$notdone << assessorstr
  			$notreceived << userstr
  		end
        myputs "<tr>"
	    str = sprintf("<td>%s</td><td>%s</td><td>%s</td>", userstr, assessorstr, comments+rubric_comments)
	    myputs str
        myputs "</tr>"
  }
end

#Trenger en oversikt over hvilken seksjon studenten tilhører slik at vi kan gi denne
#informasjonen i tabellen.
SiktUtility.populateSectionHash($cid)


t = Time.now

#filename = sprintf("%s%s%s%s.html", t.strftime("%Y"), t.strftime("%m"), t.strftime("%d"), fid)

courseName = getCourseInfo($cid)
assignmentName = getAssignmentName($cid, $aid)

cn = courseName.gsub(/[^0-9A-Za-z]/, '')
an = assignmentName.gsub(/[^0-9A-Za-z]/, '')
filename = sprintf("%s_%s_hverandrevurderinger.html", cn, an)

$file = OpenFile(filename)


myputs("<!DOCTYPE html><html><body>
<head>
<meta charset='UTF-8'>

<style>
table, td, th {
    border: 1px solid green;
}
th {
    background-color: green;
    color: white;
}

</style>
</head>
")

myputs "Dato: " + t.inspect

heading = sprintf("<h1>%s</h1>", assignmentName)
myputs heading

myputs "<table>"
uri = sprintf("/api/v1/courses/%d/assignments/%d/peer_reviews?include[]=submission_comments&include[]=user&per_page=1000", $cid, $aid)
printHeading()

list = $canvas.get(uri)
processReviews(list)
while list.more?  do
  list = list.next_page!
  processReviews(list)
end
myputs "</table>"

myputs "<h2>Har ikke gjort hverandrevurdering</h2>"
myputs "<table><tr><th>Name</th></tr>"
  $notdone.each { |s|
     str = sprintf("<tr><td>%s</td></tr>", s)
     myputs(str)
  }
myputs "</table>"

myputs "<h2>Har ikke mottatt hverandrevurdering</h2>"
myputs "<table><tr><th>Name</th></tr>"
  $notreceived.each { |s|
     str = sprintf("<tr><td>%s</td></tr>", s)
     myputs(str)
  }
myputs "</table>"


myputs "</body></html>"

CloseFile()


