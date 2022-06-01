require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions'

dst = ARGV[0]
accountId = ARGV[1]
s = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta aid innhold")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Søker etter innhold i kurs i kontoen med id aid")
	exit
end

$canvas = getCanvasConnection(dst)
dbg($canvas)

def findInCourses(courses, s)
    courses.each { |c|
        printf "<h1>%s</h1>", c["name"]
        cid = c["id"]
        list = getPages(cid)
        searchFor(cid, list, $pageType, s)
        while list.more?  do
          list = list.next_page!
          searchFor(cid, list, $pageType, s)
        end

        list = getDiscussions(cid)
        searchFor(cid, list, $discussionType, s)
        while list.more?  do
          list = list.next_page!
          searchFor(cid, list, $discussionType, s)
        end

        list = getAssignments(cid)
        searchFor(cid, list, $assignmentType, s)
        while list.more?  do
          list = list.next_page!
          searchFor(cid, list, $assignmentType, s)
        end

        list = getQuizzes(cid)
        searchFor(cid, list, $quizType, s)
        while list.more?  do
          list = list.next_page!
          searchFor(cid, list, $quizType, s)
        end
    }
end

puts "<html><body>"
courses = getCourses(accountId)
findInCourses(courses,s)
while courses.more?  do
  list = courses.next_page!
  findInCourses(courses,s)
end
puts "</body></html>"


