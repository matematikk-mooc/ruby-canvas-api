require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 1)
	dbg("Usage: ruby #{$0} prod/beta ")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lister ut kursene på serveren som er tilgjengelige via search/all_courses.")
	exit
end

dst = ARGV[0]
accountid = ARGV[1]
frmt = ARGV[2]

$canvas = getCanvasConnection(dst)


def getNoOfActiveStudentsForCourse(courseId)
    noOfEnrollments = 0
    enrollmentsuri = sprintf("/api/v1/courses/%d/enrollments?type[]=StudentEnrollment&state[]=active", courseId)
    enrollmentlist = $canvas.get(enrollmentsuri)
    noOfEnrollments = noOfEnrollments + enrollmentlist.length
    while enrollmentlist.more?  do
      enrollmentlist = enrollmentlist.next_page!
      noOfEnrollments = noOfEnrollments + enrollmentlist.length
    end
    return noOfEnrollments
end

def processCourses(list)
    list.each { |c|
        courseId = c['course']['id']
        noOfEnrollmentsInCourse = getNoOfActiveStudentsForCourse(courseId)
        printf("%s\t%s\t%d\n", courseId, c['course']['name'], noOfEnrollmentsInCourse)
    } 

end

uri = sprintf("/api/v1/search/all_courses?per_page=999")

printf("Id\tKursnavn\tAktive studenter\n")

list = $canvas.get(uri)
processCourses(list)
while list.more?  do
  list = list.next_page!
  processCourses(list)
end
