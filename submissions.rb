#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions' 

dst = ARGV[0]
cid = ARGV[1]
aid = ARGV[2]
$no = 0
$notot = 0


if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid aid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lager en fil med innleveringsinformasjon for oppgave med aid per seksjon.")
	exit
end

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


def processSubmissions(submissions)
  subm = 0
  submissions.each { |submission| 
	dbg(submission["user_id"])
	s = getUserProfile(submission["user_id"])
  	comments = getComments(submission["submission_comments"])
  	rubric_comments = getRubricComments(submission["rubric_assessment"])
	
#	g = getUserProfile(canvas, submission["grader_id"])
	str = sprintf("<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>", submission["user_id"], s["name"],submission["grade"], comments+rubric_comments)
	myputs str
	subm += 1
  }
  return subm
end

def printHeading()
    myputs("<tr><th>User id</th><th>Navn</th><th>Karakter</th><th>Kommentarer</th></tr>")
end


def processSection(sid, aid, sectionName)
    enrollments = getEnrollmentsInSection(sid)
    dbg("=================================")
    dbg(sectionName)
	s = sprintf("<h2>Seksjon: %s id:%d</h2>", sectionName,sid)
	myputs(s)
	myputs "<table>"
	
	#GET /api/v1/sections/:section_id/assignments/:assignment_id/peer_reviews
	uri = sprintf("/api/v1/sections/%d/assignments/%d/submissions?include[]=submission_comments&include[]=rubric_assessment&per_page=1000",sid,aid)
	printHeading()
	nobefore = $no

	submissions = $canvas.get(uri)
	subm = 0
	subm += processSubmissions(submissions)
 	while submissions.more?  do
	  submissions = submissions.next_page!
	  subm += processSubmissions(submissions)
 	end
    $no=$no+subm
    $notot += enrollments.size
	myputs "</table>"
	noafter = $no
	sno = noafter-nobefore
	s = sprintf("<h2>Totalt har %d av %d studenter levert oppgaven i denne seksjonen</h2>", sno, enrollments.size)
	myputs(s)
end


t = Time.now

#filename = sprintf("%s%s%s%s.html", t.strftime("%Y"), t.strftime("%m"), t.strftime("%d"), fid)

courseName = getCourseInfo(cid)
assignmentName = getAssignmentName(cid, aid)

cn = courseName.gsub(/[^0-9A-Za-z]/, '')
an = assignmentName.gsub(/[^0-9A-Za-z]/, '')
filename = sprintf("%s_%s_submissions.html", cn, an)

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

uri = sprintf("/api/v1/courses/%d/sections?per_page=1000",cid)
sections = $canvas.get(uri)
sections.each { |section| 
	processSection(section["id"], aid, section["name"])
	while sections.more?  do
	  sections = sections.next_page!
	  processSection(section["id"],aid, section["name"])
	end
}
s = sprintf("<h2>Totalt har %d av %d studenter levert oppgaven</h2>", $no, $notot)
myputs(s)
myputs "</body></html>"

CloseFile()

