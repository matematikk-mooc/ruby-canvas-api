#Forfatter: Erlend Thune (erlend.thune@iktsenteret.no)
#Dato: Høsten 2015
#Skrevet i forbindelse med prosjektet matematikkMOOC


def dbg(s)
	STDERR.puts s
end

#Legg bruker uid til gruppe groupId
def addUserToGroup(uid, groupId)
      uri = sprintf("/api/v1/groups/%d/memberships", groupId)
	 $canvas.post(uri, {'user_id' => uid})
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

def getAssignments(cid)
	uri = sprintf("/api/v1/courses/%d/assignments", cid)
    l = $canvas.get(uri)
    return l
end
