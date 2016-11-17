require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions'

dst = ARGV[0]
cid = ARGV[1]
mid = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid mid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Sjekker manglende krav etc. i kurs med id cid og modul med id mid.")
	exit
end
$canvas = getCanvasConnection(dst)
dbg($canvas)

dbg("START")

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


def printRow(c1,c2)
	myputs "<tr>"
	myputs "<td>"
	myputs c1
	myputs "</td>"
	myputs "<td>"
	myputs c2
	myputs "</td>"
	myputs "</tr>"
end

def printRedRow(c1,c2)
	myputs "<tr>"
	myputs "<td class='nok'>"
	myputs c1
	myputs "</td>"
	myputs "<td>"
	myputs c2
	myputs "</td>"
	myputs "</tr>"
end

def printPageTable(cid, x)
	req = x["completion_requirement"]
	if req
		reqtype = req["type"]
		if(reqtype != "must_mark_done")
			printRedRow("Krav:", reqtype)
		end
	end
end

def printFileTable(cid, x)
	req = x["completion_requirement"]
	if req
		reqtype = req["type"]
		if(reqtype != "must_mark_done")
			printRedRow("Krav:", reqtype)
		end
	end
end

def printDiscussionTable(cid, x)
	req = x["completion_requirement"]
	if req
		reqtype = req["type"]
		if(reqtype != "must_contribute")
			printRedRow("Krav:", reqtype)
		end
	end
	content_id = x["content_id"]
	d = getDiscussion(cid, content_id)
	if(d["discussion_type"] != "side_comment")
		printRedRow("Trådtype:", d["discussion_type"])
	else
		printRow("Trådtype:", d["discussion_type"])
	end
	gid = d["group_category_id"]
	if(gid)
		g = getGroupCategory(gid)
		printRow("Gruppekategori:", g["name"])
	else
		printRedRow("Gruppekategori:", "Mangler")
	end
	printRow("Steng:", d["lock_at"])
end

def printAssignmentTable(cid, x)
	req = x["completion_requirement"]
	if req
		reqtype = req["type"]
		if(reqtype != "must_submit")
			printRedRow("Krav:", reqtype + " på innleveringsoppgave.")
		end
	end
	content_id = x["content_id"]
	a = getAssignment(cid, content_id)
	printRow("Frist:", a["due_at"])
	printRow("Hverandrevurdering:", a["peer_reviews"])
	hvvfrist = "-"
	if(a["automatic_peer_reviews"])
		hvvfrist = a["peer_reviews_assign_at"]
	end
	printRow("Hverandrevurderingsfrist:", hvvfrist)
end

#  // the type of object referred to one of 'File', 'Page', 'Discussion',
#  // 'Assignment', 'Quiz', 'SubHeader', 'ExternalUrl', 'ExternalTool'


def printSanityTableForItem(cid, mid, x)
	myputs "<table>"
	dbg("printSanityTableForItem")
	type = x["type"]
	if(type == "Assignment")
		printAssignmentTable(cid, x)
	elsif(type == "Discussion")
		printDiscussionTable(cid, x)
	elsif(type == "Page")
		printPageTable(cid, x)
	elsif(type == "Quiz")
		printQuizTable(cid, x)
	elsif(type == "File")
		printFileTable(cid, x)
	end
	myputs "</table>"
end

def printSanityTableForModule(cid, mid)
    myputs("<tr><th>Innholdselement</th><th>Publisert</th><th>Krav</th><th>Detaljer</th></tr>")

    uri = sprintf("/api/v1/courses/%d/modules/%d/items?per_page=999", cid, mid)
	dbg(uri)
    moduleItems = $canvas.get(uri)

	moduleItems.each { |x| 
		myputs("<td>")
		myputs(x["title"])
		myputs("</td>")
		
		if x["published"]
			myputs("<td class='ok'>JA</td>")
			req = x["completion_requirement"]
			if req
				myputs("<td class='ok'>")
				reqtype = req["type"]
				myputs(reqtype)
				myputs(" ")
				if(reqtype == "min_score")
					min_score = req["min_score"]
					myputs(min_score)
				end
				myputs("</td>")
				
			else
				myputs("<td class='nok'></td>")
			end

		else
			myputs("<td class='nok'>NEI</td>")
		end
		myputs "<td>"
		printSanityTableForItem(cid, mid, x)
		myputs "</td>"
		myputs("</tr>")
	}
	
end



def getModuleInfo(cid, mid)
	uri = sprintf("/api/v1/courses/%d/modules/%d", cid, mid)
	dbg(uri)
    m = $canvas.get(uri)
    return m["name"]
end

def getCourseInfo(cid)
	uri = sprintf("/api/v1/courses/%d", cid)
	dbg(uri)
	dbg($canvas)
    c = $canvas.get(uri)
    return c["name"]
end

courseName = getCourseInfo(cid)
moduleInfo = getModuleInfo(cid, mid)

cn = courseName.gsub(/[^0-9A-Za-z]/, '')
mn = moduleInfo.gsub(/[^0-9A-Za-z]/, '')
filename = sprintf("SANITY_%s_%s.html", cn, mn)

dbg("OpenFile")

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

t = Time.now




myputs "Dato: " + t.inspect
heading = sprintf("<h1>%s</h1>", moduleInfo)
myputs heading
myputs "<table>"

printSanityTableForModule(cid, mid)
myputs "</table>"

myputs "</body></html>"
CloseFile()

dbg("CloseFile")
dbg("END")


