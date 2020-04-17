#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'siktfunctions'
require_relative 'connection'  

dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Skriver oversikt til fil over hvem som har gjort hva i kurset med kurs id cid.")
	exit
end
canvas = getCanvasConnection(dst)

#Array where the key is item id and the value is how many students have completed the item. 
$gcompleted = nil

#Array where the key is item id and the value is how many student could have completed the item.
#Could probably just have a global variable for the total number of students in the course. 
$gcompletedpossible = nil

#Array where the key is module id and the value is how many students have completed the item for one section. 
$gmodulecompleted = nil

#Array where the key is module id and the value is how many students could have completed the item. 
#Could probably just have a global variable for the total number of students in the course.
$gmodulecompletedpossible = nil


#Array where the key is the student id and the value is a boolean telling whether the student has completed all the requirements in the course.
$gcoursecompleted = nil

#Same as above but grouped by users domain, i.e. everything after @ in the login id, f.ex. eth@udir.no has domain udir.no
$gcoursedomaincompleted = nil
$gcoursedomaincompletedpossible = nil
$guniquestudents = nil

$file = nil
$shfile = nil
$coursefile = nil

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

def OpenCourseStatisticsFile(name)
	$coursefile = File.open(name,"w" )
end

def CloseCourseStatisticsFile()
	$coursefile.close
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

def csputs(s)
	$coursefile << s
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
		
		#Initialize array elements:
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

def printModuleItemsRowForUser(canvas, cid, mid, sid, login_id)
    uri = sprintf("/api/v1/courses/%d/modules/%d/items?student_id=%d", cid, mid, sid)
    dbg(uri)
    moduleItems = canvas.get(uri)
    c = 0
    cl = 0
    $guniquestudents[login_id] = true;
    
	moduleItems.each { |x| 
			id=x["id"]
			req = x["completion_requirement"]
			if req
				#This item could be completed by the student
			    $gcompletedpossible[id] += 1
			    c += 1
				completed = req["completed"]
				if completed
					#This item has been completed by the student.
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
	if(cl == c)
		#The student has completed the module
 		$gmodulecompleted[mid] += 1

 		#If this is the first module, the students course completion has not been set, and
 		#we set the course completion entry for the student to true:
 		if($gcoursecompleted[login_id] == nil)
			$gcoursecompleted[login_id] = true
		end
 	else
 	    #The module has not been completed, therefore the course has not been completed by the student.
		$gcoursecompleted[login_id] = false
	end
	str = sprintf("<td>%d/%d</td>", cl,c)
	myputs(str)
end

def getUserProfile(canvas, sid)
    uri = sprintf("/api/v1/users/%d/profile",sid)
    profile = canvas.get(uri)
    return profile
end

def getUserDomainFromLoginId(login_id) 
  return login_id.partition('@').last  
end

def processUsers(canvas, cid, mid, list)
  list.each { |s| 
        myputs "<tr>"
	    profile = getUserProfile(canvas, s["user_id"])
  		dbg(profile["name"])
  		dbg(profile);
	    str = sprintf("<td>%d</td><td>%s</td>", s["user_id"], profile["name"])
	    myputs str
   		printModuleItemsRowForUser(canvas, cid, mid, s["user_id"], profile["login_id"])
        myputs "</tr>"
  }
  myputs "</tr>"
end

def getModuleInfo(canvas, cid, mid)
	uri = sprintf("/api/v1/courses/%d/modules/%d", cid, mid)
	dbg(uri)
    m = canvas.get(uri)
    return m["name"]
end

def getCourseInfo(canvas, cid)

	uri = sprintf("/api/v1/courses/%d", cid)
	dbg(uri)
    c = canvas.get(uri)
    return c["name"]
end

def processSection(canvas, cid, mid, sectionid, sectionName)
	dbg(sectionName)

	csputs(sectionName)
	csputs(";")
	moduleInfo = getModuleInfo(canvas, cid, mid)
	csputs(moduleInfo);
	csputs(";");
	
  $gmodulecompleted[mid] = 0
  $gmodulecompletedpossible[mid] = 0

	s = sprintf("<h2>%s</h2>", sectionName)
	myputs(s)
	myputs "<table>"
	uri = sprintf("/api/v1/sections/%d/enrollments?type[]=StudentEnrollment", sectionid)
	printHeading(canvas, cid, mid)

	list = canvas.get(uri)
	
	#Store the number of students that can complete the module: 
 	$gmodulecompletedpossible[mid] += list.size

	processUsers(canvas,cid, mid, list)
	while list.more?  do
	  list = list.next_page!
	  #Add the number of students that can complete the module: 
 	  $gmodulecompletedpossible[mid] += list.size
	  processUsers(canvas,cid, mid, list)
	end
	myputs "<tr><td></td><td></td>"

  	#Run through all the items and print the total number completed.
    $gcompleted.each {|k, v|
    	total = $gcompletedpossible[k]
	    if(total == 0)
    	 	myputs("-")
	    else
	      	str = sprintf("<td>%d/%d</td>", v, total)
		 	myputs(str)
   	    end
    }
	myputs "<td></td></tr>"
	myputs "</table>"
	myputs "Modulgjennomføringsgrad:"
  	str = sprintf("<td>%d/%d</td>", $gmodulecompleted[mid], $gmodulecompletedpossible[mid])
	myputs(str)
	csputs($gmodulecompleted[mid])
	csputs(";")
	csputs($gmodulecompletedpossible[mid])
	percentcompleted = $gmodulecompleted[mid] * 100 / $gmodulecompletedpossible[mid]
	csputs(";")
	csputs(percentcompleted)
	csputs("\n")
	dbg("Percent completed:")
	dbg(percentcompleted)
    dbg($gcompletedpossible)
    dbg($gcompleted)
  	return $gmodulecompletedpossible[mid]
end

def processSections(canvas, cid, mid, sections)
	noOfStudents = 0
	sections.each { |section| 
		noOfStudents = noOfStudents + processSection(canvas,cid, mid, section["id"], section["name"])
	}
	return noOfStudents
end

def updateUserDomains()
	$guniquestudents.each { |k, v|
    userdomain = getUserDomainFromLoginId(k) 
    if($gcoursedomaincompletedpossible[userdomain] == nil)
      $gcoursedomaincompletedpossible[userdomain] = 1
    else
      $gcoursedomaincompletedpossible[userdomain] += 1
    end
  }
end


def getNoOfStudentsThatHavePassedTheCourse()
	p = 0
	$gcoursecompleted.each { |k, v|
		if( v == true )
      userdomain = getUserDomainFromLoginId(k) 
      dbg("Userdomain:" + userdomain)
      if($gcoursedomaincompleted[userdomain] == nil)
        $gcoursedomaincompleted[userdomain] = 1
      else
        $gcoursedomaincompleted[userdomain] += 1
      end
			p += 1
		end
	}
	return p
end

def printHtmlHeader(moduleInfo)
myputs("<!DOCTYPE html><html>
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
<body>
")
t = Time.now
myputs "Dato: " + t.inspect
myputs "<ul><li>Grønn farge = krav innfridd</li>
<li>Rød farge = krav ikke innfridd</li>
<li>Hvit farge = ikke krav</li>
<li>Hvit linje = studenten har ikke vært inne i kurset</li>
</ul>
"
heading = sprintf("<h1>%s</h1>", moduleInfo)
myputs heading
end



#filename = sprintf("%s%s%s%s.html", t.strftime("%Y"), t.strftime("%m"), t.strftime("%d"), fid)

def CreateFile(cn, mn)
	filename = sprintf("%s_%s.html", cn, mn)

	$file = OpenFile(filename)
end

courseName = getCourseInfo(canvas, cid)
cn = courseName.gsub(/[^0-9A-Za-z]/, '')
csfilename = sprintf("%s.csv", cn)
OpenCourseStatisticsFile(csfilename)
csputs("Seksjon;Modulnavn;Gjennomført;Mulige;Prosent\n")
$gmodulecompleted = Hash.new
$gmodulecompletedpossible = Hash.new
$gcoursecompleted = Hash.new
$gcoursedomaincompleted = Hash.new
$gcoursedomaincompletedpossible = Hash.new
$guniquestudents = Hash.new

#	processSection(canvas,cid, mid, 154, "Testseksjon")
uri = sprintf("/api/v1/courses/%d/modules?per_page=99", cid)
modules = canvas.get(uri)
puts modules
noOfStudents = 0
modules.each { |m|
	if(m["published"] == true)
		$gcompleted = Hash.new
		$gcompletedpossible = Hash.new

		puts m
		mid = m["id"]
		moduleInfo = getModuleInfo(canvas, cid, mid)
		mn = moduleInfo.gsub(/[^0-9A-Za-z]/, '')
		CreateFile(cn, mn)
		printHtmlHeader(moduleInfo)
		uri = sprintf("/api/v1/courses/%d/sections",cid)
		sections = canvas.get(uri)
		noOfStudents = processSections(canvas, cid, mid, sections)
		while sections.more?  do
		  sections = sections.next_page!
		  noOfStudents = noOfStudents + processSections(canvas, cid, mid, sections)
		end

		myputs "</body></html>"
		CloseFile()
	else
		dbg("SKIP UNPUBLISHED MODULE")
	end
}

p = getNoOfStudentsThatHavePassedTheCourse()

csputs("Kursgjennomføringer")
csputs(";")
csputs("Mulige kursgjennomføringer")
csputs(";")
csputs("Prosent\n")
#passed
csputs(p)
csputs(";")
#possible
csputs(noOfStudents)
csputs(";")
#percent
if(noOfStudents == 0)
  csputs("Ingen studenter i kurset")
else
	csputs(p*100/noOfStudents)
end
csputs("\n")

csputs("\nKursgjennomføringer per domene\n")
csputs("Domene;Antall;Mulige;Prosent")
$gcoursedomaincompleted.each {|k, v|
  total = $gcoursedomaincompletedpossible[k]
  if(total == 0)
    csputs("0;0;0")
  else
    str = sprintf("%s;%d;%d;%d", k, v, total, v/total*100)
    myputs(str)
  end
}

CloseCourseStatisticsFile()


