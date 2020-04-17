#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions'  

dst = ARGV[0]
cid = ARGV[1]
mid = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid mid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Skriver oversikt over hvem som har gjort hva i kurset cid modulen mid.")
	exit
end
canvas = getCanvasConnection(dst)

$gcompleted = Hash.new
$gcompletedpossible = Hash.new

$file = nil
$shfile = nil

def dbg(s)
	STDERR.puts s
end

def OpenFile(filename)
	$file = File.open( filename,"w" )
end

def OpenShFile()
	$file = File.open( "statistikk.sh","w" )
end

def CloseShFile()
	$shfile.close
end

def CloseFile()
	$file.close
end

def myputs(s)
	$file << s
end

def shputs(s)
	$file << s
end

def printHeading(canvas, cid, mid)
    myputs("<tr><th>Id</th><th>Navn</th>")

    uri = sprintf("/api/v1/courses/%d/modules/%d/items", cid, mid)
	dbg(uri)
    moduleItems = canvas.get(uri)
	moduleItems.each { |x| 
		myputs("<th>")
		myputs(x["title"])
		myputs("<br/>")
		id = x["id"]
		dbg("id:")
		dbg(id)
		dbg($gcompletedpossible[id])
		$gcompletedpossible[id] = 0
		$gcompleted[id] = 0 
		if x["published"]
			req = x["completion_requirement"]
			if req
				reqtype = req["type"]
				myputs(reqtype)
				myputs(" ")
				if(reqtype == "min_score")
					min_score = req["min_score"]
					myputs(min_score)
				end
			else
				s=sprintf("Ingen krav")
				myputs(s)
			end

		else
			s=sprintf("(IKKE PUBLISERT)")
			myputs(s)
		end
		myputs("</th>")
	}
	
	myputs("<th>% fullført</tr>")
end

def printModuleItemsRowForUser(canvas, cid, mid, sid)
    uri = sprintf("/api/v1/courses/%d/modules/%d/items?student_id=%d", cid, mid, sid)
    moduleItems = canvas.get(uri)
    cl = 0
	moduleItems.each { |x| 
			id=x["id"]
		    c = $gcompletedpossible[id]
		    dbg("id:")
		    dbg(id)
		    dbg(c)
		    c += 1
		    $gcompletedpossible[id] = c
			req = x["completion_requirement"]
			if req
				completed = req["completed"]
				if completed
				    $gcompleted[id] += 1
					cl += 1
					myputs "<td class='ok'/>"
				else
					myputs "<td class='nok'/>"
				end
			else
				myputs "<td>&nbsp;</td>"
			end
	}
	str = sprintf("<td>%d/%d</td>", cl,moduleItems.size)
	myputs(str)
end

def getUserProfile(canvas, sid)

    uri = sprintf("/api/v1/users/%d/profile",sid)
    profile = canvas.get(uri)
    return profile
end



def processUsers(canvas, cid, mid, list)
  list.each { |s| 
        myputs "<tr>"
	    profile = getUserProfile(canvas, s["user_id"])
	    str = sprintf("<td>%d</td><td>%s</td>", s["user_id"], profile["name"])
	    myputs str
		printModuleItemsRowForUser(canvas, cid, mid, s["user_id"])
        myputs "</tr>"
  }
  myputs "<tr><td></td><td>%</td>"
  dbg($gcompletedpossible)
  dbg($gcompleted)
  $gcompleted.each {|k, v|
     total = $gcompletedpossible[k]
     if(total == 0)
     	myputs("-")
     else
       	 str = sprintf("<td>%d/%d</td>", v, total)
	  	 myputs(str)
	 end
  }
  myputs "</tr>"
end

def getModuleInfo(canvas, cid, mid)
	uri = sprintf("/api/v1/courses/%d/modules/%d", cid, mid)
    m = canvas.get(uri)
    return m["name"]
end

def getCourseInfo(canvas, cid)

	uri = sprintf("/api/v1/courses/%d", cid)
    c = canvas.get(uri)
    return c["name"]
end

def processSection(canvas, cid, mid, sectionid, sectionName)
	dbg(sectionName)
	
	s = sprintf("<h2>%s</h2>", sectionName)
	myputs(s)
	myputs "<table>"
	uri = sprintf("/api/v1/sections/%d/enrollments?type[]=StudentEnrollment", sectionid)
	printHeading(canvas, cid, mid)

	list = canvas.get(uri)
	processUsers(canvas,cid, mid, list)
	while list.more?  do
	  list = list.next_page!
	  processUsers(canvas,cid, mid, list)
	end
	myputs "</table>"

end

def processSections(canvas, cid, mid, sections)
	sections.each { |section| 
		processSection(canvas,cid, mid, section["id"], section["name"])
	}
end


t = Time.now

#filename = sprintf("%s%s%s%s.html", t.strftime("%Y"), t.strftime("%m"), t.strftime("%d"), fid)

courseName = getCourseInfo(canvas, cid)
moduleInfo = getModuleInfo(canvas, cid, mid)

cn = courseName.gsub(/[^0-9A-Za-z]/, '')
mn = moduleInfo.gsub(/[^0-9A-Za-z]/, '')
filename = sprintf("%s_%s.html", cn, mn)

$file = OpenFile(filename)


myputs("<!DOCTYPE html><html><body>
<head>
<meta charset='UTF-8'>

<style>
table, td, th {
    border: 1px solid green;
}
td.ok {
    background-color: green;
    color: white;
}
td.nok {
    background-color: red;
    color: white;
}

th {
    background-color: green;
    color: white;
}

</style>
</head>
")

myputs "Dato: " + t.inspect

myputs "<ul><li>Grønn farge = krav innfridd</li>
<li>Rød farge = krav ikke innfridd</li>
<li>Hvit farge = ikke krav</li>
<li>Hvit linje = studenten har ikke vært inne i kurset</li>
</ul>
"
heading = sprintf("<h1>%s</h1>", moduleInfo)
myputs heading

#	processSection(canvas,cid, mid, 154, "Testseksjon")
uri = sprintf("/api/v1/courses/%d/sections",cid)
sections = canvas.get(uri)
processSections(canvas, cid, mid, sections)
while sections.more?  do
  sections = sections.next_page!
  processSections(canvas, cid, mid, sections)
end
myputs "</body></html>"

CloseFile()


