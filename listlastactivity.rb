require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta courseid]")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lister ut enrollments statistikk per dag for kurs med id courseid.")
	exit
end

dst = ARGV[0]
courseId = ARGV[1]

$canvas = getCanvasConnection(dst)

def OpenFile(filename)
	return File.open( filename,"w" )
end
def CloseFile(file)
	file.close
end

def myputs(file,s)
	file << s
end

def processEnrollments(list)
    list.each { |e|
        myputs($file2, "#{e["user_id"]}\t#{e["last_activity_at"]}\n");
    } 
end
$file2 = OpenFile("enrollments#{courseId}.csv")
page = 1
puts "page #{page}"
list = getEnrollmentsForCourseForAllUserTypes(courseId)
processEnrollments(list)
page += 1

while list.more?  do
  puts "page #{page}"
  list = list.next_page!
  processEnrollments(list)
  page += 1
end

CloseFile($file2)
