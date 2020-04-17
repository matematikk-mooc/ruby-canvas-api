#Forfatter: Erlend Thune (erlend.thune@iktsenteret.no)
#Dato: Høsten 2015
#Skrevet i forbindelse med prosjektet matematikkMOOC

require 'colorize'
require 'uri'

def dbg(s)
	STDERR.puts s
end

#/api/v1/accounts/:account_id/logins
def addLoginToUser(account_id, user_id, login_id)
    uri = sprintf("/api/v1/accounts/%d/logins", account_id)
	 $canvas.post(uri, {
	 'user[id]' => user_id,
	 'login[unique_id]' => login_id}
	 )
end
#Legg bruker uid til gruppe groupId
def addUserToGroup(uid, groupId)
      uri = sprintf("/api/v1/groups/%d/memberships", groupId)
	 $canvas.post(uri, {'user_id' => uid})
end
 
def createPage(cid, title, body)
    uri = sprintf("/api/v1/courses/%d/pages", cid)
    newPage = $canvas.post(uri, {'wiki_page[title]' => title, 'wiki_page[body]' => body })
    dbg(newPage)
    return newPage
end

def createModuleItem(cid, mid, type, content, position)
  uri = sprintf("/api/v1/courses/%d/modules/%d/items", cid, mid) 
  dbg(uri)
  newModuleItem = $canvas.post(uri, {'module_item[page_url]' => content["url"],'module_item[type]' => type, 'module_item[content_id]' => content["id"], 'module_item[position]' => position})
  dbg(newModuleItem)
  return newModuleItem
end 
 
#Opprett gruppe med navn groupName i gruppesettet gid.
def createGroup(groupName, gid)
  uri = sprintf("/api/v1/group_categories/%d/groups", gid) 
  
  dbg("POST #{uri}")
  dbg("name=#{groupName}")
  newGroup = $canvas.post(uri, {'name' => groupName})
  dbg(newGroup)
  return newGroup
end

def createGroupCategory(cid, categoryName)
  uri = sprintf("/api/v1/courses/%d/group_categories", cid) 
  
  dbg("POST #{uri}")
  dbg("name=#{categoryName}")
  newGroupCategory = $canvas.post(uri, {'name' => categoryName})
  dbg(newGroupCategory)
  return newGroupCategory
end

def getGroupCategory(gid)
  uri = sprintf("/api/v1/group_categories/%d", gid) 
  dbg(uri)
  groupCategory = $canvas.get(uri)
  return groupCategory
end

#Returner enrollment type for en seksjon s
def getEnrollmentType(s)
#  //The enrollment type. One of 'StudentEnrollment', 'TeacherEnrollment',
#  //'TaEnrollment', 'DesignerEnrollment', 'ObserverEnrollment'.
#  "type": "StudentEnrollment",
	type = ""
	case s["type"]
	when "StudentEnrollment"
	  type = "student"
	when "TeacherEnrollment"
	  type = "teacher"
	end
	return type
end

def getUserFromSisUserId(sis_user_id)
    uri = sprintf("/api/v1/users/sis_user_id:%s",sis_user_id)
	dbg(uri)
    user = $canvas.get(uri)
    return user
end

#Returner profilen til bruker uid
def getUserProfile(uid)
    uri = sprintf("/api/v1/users/%d/profile",uid)
    dbg(uri)
    profile = $canvas.get(uri)
    return profile
end

#Returner de to siste karakterene i seksjonsnavnet. Tanken er at seksjonene er
#nummerert "Seksjon 01" etc.
def getSectionNo(section)
	return section["name"][-2,2]
end

#Returner en liste av kommentarer. 
def getComments(list)
  comments = ""
  dbg("Kommentarer:")
  list.each { |s| 
    dbg("Kommentar:")
    dbg(s)
    dbg(s["comment"])
  	comments = comments + "<p>" + s["author_name"] + ":" + s["comment"] + "</p>"
  	dbg(s["comment"])
  }
  return comments
end

#Returner en liste av kommentarer skrevet i vurderingsskjemaet.
#Vær oppmerksom på at dersom flere har skrevet i vurderingsskjemaet, f.eks. en faglærer og 
#en student, så vil bare kommentarene til en av disse brukerne returneres. Det er litt uklart
#hvorfor Canvas API'et gjør det slik. Muligens en svakhet i API'et ettersom man i GUI kan velge
#for hvilken bruker man ønsker å se kommentarene.
def getRubricComments(list)
  if(list == nil)
	return ""
  end
  comments = "Kriteriekommentarer:"
  dbg("Kriteriekommentarer:")
  list.each { |key, value| 
    dbg("Kriteriekommentar:")
  	dbg("Key:#{key} Value:#{value}")
  	comments = comments + "<p>" + value["comments"] + "</p>"
  }
  return comments
end

def getModuleItemsForStudent(cid, mid, sid)
    uri = sprintf("/api/v1/courses/%d/modules/%d/items?student_id=%d&per_page=100", cid, mid, sid)
    puts(uri)
    moduleItems = $canvas.get(uri)
    return moduleItems
end

def getModuleItems(cid, mid)
    uri = sprintf("/api/v1/courses/%d/modules/%d/items?per_page=100", cid, mid)
    puts uri
    moduleItems = $canvas.get(uri)
    return moduleItems
end

def getCourses(accountId)
    uri = sprintf("/api/v1/accounts/%d/courses?include[]=teachers&per_page=999", accountId)
    list = $canvas.get(uri)
    return list
end


def getModules(cid)
	uri = sprintf("/api/v1/courses/%d/modules?per_page=99", cid)
	modules = $canvas.get(uri)
	return modules
end

def getPages(cid)
	uri = sprintf("/api/v1/courses/%d/pages?per_page=999", cid)
	list = $canvas.get(uri)
	return list
end
def getPageData(cid, url)
	uri = sprintf("/api/v1/courses/%d/pages/%s", cid, url)
	r = $canvas.get(uri)
	return r["body"]
end

def getEnrollmentsForCourse(courseId)
	uri = sprintf("/api/v1/courses/%d/enrollments?role[]=StudentEnrollment&per_page=50", courseId)
	enrollments = $canvas.get(uri)
	return enrollments
end

#Returner en liste av enrollments i seksjon sid.
def getEnrollmentsInSection(sid)
	uri = sprintf("/api/v1/sections/%d/enrollments?type[]=StudentEnrollment&per_page=999", sid)
	enrollments = $canvas.get(uri)
	return enrollments
end

#Returner navnet på den som blir hverandrevurdert.
def getUserName(s)
    return s["display_name"]
end

#Returner navnet på hverandrevurdereren.
def getAssessorName(s)
    return s["display_name"]
end

#Returner navnet på kurs cid.
def getCourseInfo(cid)
	uri = sprintf("/api/v1/courses/%d", cid)
	dbg(uri)
    c = $canvas.get(uri)
    return c["name"]
end

#Returner navnet på modul mid i kurs cid.
def getModuleName(cid, mid)
	uri = sprintf("/api/v1/courses/%d/modules/%d", cid, mid)
    m = $canvas.get(uri)
    return m["name"]
end

#Returner navnet på en oppgaven aid i kurset cid.
def getAssignmentName(cid, aid)
	uri = sprintf("/api/v1/courses/%d/assignments/%d", cid, aid)
    a = $canvas.get(uri)
    return a["name"]
end

def getAssignment(cid, aid)
	uri = sprintf("/api/v1/courses/%d/assignments/%d", cid, aid)
    a = $canvas.get(uri)
    return a
end

def getAssignments(cid)
	uri = sprintf("/api/v1/courses/%d/assignments?per_page=1000", cid)
    l = $canvas.get(uri)
    return l
end

def getQuiz(cid, qid)
	uri = sprintf("/api/v1/courses/%d/quizzes/%d", cid,qid)
    l = $canvas.get(uri)
    return l
end

def getQuizzes(cid)
	uri = sprintf("/api/v1/courses/%d/quizzes", cid)
    l = $canvas.get(uri)
    return l
end

def deleteDiscussion(cid, did)
    $uri = sprintf("/api/v1/courses/%d/discussion_topics/%d", cid, did)
    $canvas.delete($uri)
end
def deleteAssignment(cid, aid)
    $uri = sprintf("/api/v1/courses/%d/assignments/%d", cid, aid)
    $canvas.delete($uri)
end

def getDiscussions(cid)
	uri = sprintf("/api/v1/courses/%d/discussion_topics", cid)
    l = $canvas.get(uri)
    return l
end

def getDiscussion(cid, did)
	uri = sprintf("/api/v1/courses/%d/discussion_topics/%d", cid, did)
	dbg(uri)
    d = $canvas.get(uri)
    return d
end

$discussionType = 0
$assignmentType = 1
$quizType = 2
$pageType = 3

def searchFor(cid, list, type, s)
	list.each { |c|
		body = ""
		title = ""
		if(type == $pageType)
            printf("<!-- %s -->", c['url'])
            body = getPageData(cid, URI.escape(c['url']))
            title = c["title"]
		elsif (type == $discussionType)
            body = c['message']
            title = c["title"]
		elsif (type == $assignmentType)
            body = c['description']
            title = c["name"]
		elsif (type == $quizType)
            body = c['description']
            title = c["title"]
		end
    #	puts body
        found = false
        if title.downcase.include? s.downcase
            found = true
        end
        if body 
            if body.downcase.include? s.downcase
                found = true
            end
        end	
        if found
            printf("<br/><a href='%s' target='_blank'>%s</a>\n", c['html_url'], title)
        end
	} 
end
