require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions'

dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Sjekker manglende krav etc. i kurs med id cid")
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
	printRow("Type:", a["submission_types"])
	printRow("Filendelse:", a["allowed_extensions"])
	
	printRow("Frist:", a["due_at"])
	printRow("Hverandrevurdering:", a["peer_reviews"])
	hvvfrist = "-"
	if(a["automatic_peer_reviews"])
		hvvfrist = a["peer_reviews_assign_at"]
	end
	printRow("Hverandrevurderingsfrist:", hvvfrist)
	printRow("Antall vurderinger:", a["peer_review_count"])
end

def printQuizTable(cid, x)
	req = x["completion_requirement"]
	if req
		reqtype = req["type"]
		if(reqtype != "min_score")
			printRedRow("Krav:", reqtype + " på quiz.")
		end
	end
	content_id = x["content_id"]
	a = getQuiz(cid, content_id)
	printRow("Frist:", a["due_at"])
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
    return m
end

def getCourseInfo(cid)
	uri = sprintf("/api/v1/courses/%d", cid)
	dbg(uri)
	dbg($canvas)
    c = $canvas.get(uri)
    return c
end



$discussionType = 0
$assignmentType = 1
$quizType = 2
$pageType = 3

def getTitle(e, type)
	title = ""
	if((type == $discussionType) || (type == $pageType))
		title = e['title']
	else
		title = e['name']
	end
	return title
end

def getPublishedString(e)
	s = "UPUBLISERT"
	if (e['published'])
		s = "PUBLISERT"
	end
	return s
end

def getContentId(e, type)
	content_id = 0
	if(type == $pageType)
		content_id = e["page_id"]
	else
		content_id = e["id"]
	end
end
def orphanElements(list, type)
	orphans = false
	list.each { |e|
#		element_id = getContentId(e, type)
		key = e["html_url"]
#		printf("Looking up %s\n", key)
#		mi = $AllModuleItems[element_id]
		mi = $AllModuleItems[key]
		#Is element orphan?
		if(!mi)
			printf "Key not found:%s\n", key;

			title = getTitle(e, type)
			s = getPublishedString(e)
			ss = sprintf("<p>%s\t%s\t<a href='%s'>%s</a></p>", s, title , key,key)
			myputs(ss)
			orphans = true
		end
	} 
	if(!orphans)
		myputs "ingen"
	end
end

$AllModuleItems = Hash.new

courseInfo = getCourseInfo(cid)
courseName = courseInfo["name"]

cn = courseName.gsub(/[^0-9A-Za-z]/, '')
filename = sprintf("SANITY_%s.html", cn)

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

printf("Henter moduler\n")
courseHeading = sprintf("<h1>%s</h1>", courseName)
coursePublished = sprintf("Publisert: %s", courseInfo["published"] ? "JA" : "NEI")

myputs courseHeading
myputs coursePublished
modules = getModules(cid)
modules.each { |m|
	mid = m["id"]
	moduleItems = getModuleItems(cid, mid)
	printf("Henter moduleelementer for modul %d\n", mid)
	moduleItems.each { |mi|
		key = mi["url"].sub!("/api/v1", "")
		printf "Add key:%s\n", key;
		$AllModuleItems[key] = mi
	}
	moduleInfo = getModuleInfo(cid, mid)
	moduleName = moduleInfo["name"]
	heading = sprintf("<h2>%s</h2>", moduleName)
	modulePublished = sprintf("Publisert: %s", moduleInfo["published"] ? "JA" : "NEI")
	myputs heading
	myputs modulePublished
	myputs "<table>"
	printSanityTableForModule(cid, mid)
	myputs "</table>"
} 

puts "Kontroller for løsrevne sider..."
myputs "<h1>Kontroller for løsrevne sider...</h1>"
list = getPages(cid)
orphanElements(list, $pageType)

puts "Kontroller for løsrevne diskusjoner..."
myputs "<h1>Kontroller for løsrevne diskusjoner...</h1>"
list = getDiscussions(cid)
orphanElements(list, $discussionType)

puts "Kontroller for løsrevne oppgaver..."
myputs "<h1>Kontroller for løsrevne oppgaver...</h1>"
list = getAssignments(cid)
orphanElements(list, $assignmentType)

puts "Kontroller for løsrevne quizer..."
myputs "<h1>Kontroller for løsrevne quizer...</h1>"
list = getQuizzes(cid)
orphanElements(list, $quizType)


myputs "</body></html>"
CloseFile()

dbg("CloseFile")
dbg("END")


