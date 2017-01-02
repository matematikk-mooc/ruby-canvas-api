#Forfatter: Erlend Thune (erlend.thune@iktsenteret.no)
#Dato: Høsten 2015
#Skrevet i forbindelse med prosjektet matematikkMOOC
require 'canvas-api'
require 'csv'

#Denne klassen skal brukes som en single instance.
#Den inneholder funksjonalitet for å 

class SiktUtility
	@@groupsHash = Hash.new
	@@sectionStudentHash = Hash.new
	@@sectionUserHash = Hash.new
	@@sectionTeacherHash = Hash.new
	@@sectionPrefix = "Studiegruppe"
	@@groupPrefix = "Studiegruppe"

  def self.groupsHash
    @@groupsHash
  end
  def self.sectionStudentHash
    @@sectionStudentHash
  end
  def self.sectionUserHash
    @@sectionUserHash
  end
  def self.sectionTeacherHash
    @@sectionTeacherHash
  end
  def self.sectionPrefix
    @@sectionPrefix
  end
  def self.groupPrefix
    @@groupPrefix
  end
 

def self.populateGroupsHash(gid)
	uri = sprintf("/api/v1/group_categories/%d/groups?per_page=999", gid)
	list = $canvas.get(uri)
	list.each { |c|
		if c['name'].start_with?(groupPrefix)      
			groupsHash[c['name'][-2,2]] = c['id']
		end
	}
end 

def self.addToStudentHash(sisid,sectionNo)
	 if sectionStudentHash[sectionNo].nil?
    	sectionStudentHash[sectionNo] = Array.new
	 end
	 dbg("Add sis id #{sisid} to student hash")
  	 sectionStudentHash[sectionNo].push(sisid)
end
def self.addToUserHash(uid,sectionNo)
   	sectionUserHash[uid] = sectionNo
    dbg("Add uid #{uid} to section #{sectionNo}")
end

def self.addToTeacherHash(sisid,sectionNo)
	 if sectionTeacherHash[sectionNo].nil?
    	sectionTeacherHash[sectionNo] = Array.new
	 end
	 dbg("Add student sis id #{sisid}")
  	 sectionTeacherHash[sectionNo].push(sisid)
end

def self.processEnrollments(list, sectionNo)
  list.each { |s| 
  	 uid = s["user_id"];
  	 dbg("Get user profile for user id #{uid}")
     profile = getUserProfile(uid)
   	 sisid = profile["sis_user_id"]

	 enrollmentType = s["type"]
	 dbg("Enrollment type #{enrollmentType}")
     case enrollmentType
	 when "StudentEnrollment"
	    addToStudentHash(sisid,sectionNo)
	    addToUserHash(uid, sectionNo)
	 when "TeacherEnrollment"
	    addToTeacherHash(sisid,sectionNo)
	    addToUserHash(uid, sectionNo)
	 end
  }
end


def self.processSection(section)
	uri = sprintf("/api/v1/sections/%d/enrollments", section["id"])
	sectionNo = getSectionNo(section)
	dbg(sectionNo)
	list = $canvas.get(uri)
	processEnrollments(list, sectionNo)
	while list.more?  do
	  list = list.next_page!
	  processEnrollments(list, sectionNo)
	end
end

def self.processSections(sections)
	sections.each { |section| 
		dbg(section["name"])
		if section["name"].start_with?(sectionPrefix) 
			processSection(section)
		end
	}
end

def self.populateSectionHash(cid)
	uri = sprintf("/api/v1/courses/%d/sections",cid)
	sections = $canvas.get(uri)
	processSections(sections)
	while sections.more?  do
	  sections = sections.next_page!
	  processSections(sections)
	end
end





end
