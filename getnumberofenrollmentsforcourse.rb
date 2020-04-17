require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta courseid]")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
    dbg("Lister ut enrollments statistikk per dag for kurs med id courseid.")
    dbg("Brukere med samme navn teller som en bruker.")
	exit
end

dst = ARGV[0]
courseId = ARGV[1]

$canvas = getCanvasConnection(dst)

$uniqueNames = Hash.new
def processEnrollments(list)
    list.each { |e|
        name = e["user"]["name"];
        if(!$uniqueNames.key?(name))
            $uniqueNames[name] = 1
        else 
            $uniqueNames[name] += 1
            puts "Skip duplicate name: #{name}"
        end
    } 
end

page = 1
puts "page #{page}"
list = getEnrollmentsForCourse(courseId)
processEnrollments(list)
page += 1

while list.more?  do
  puts "page #{page}"
  list = list.next_page!
  processEnrollments(list)
  page += 1
end

uniqueNames = $uniqueNames.sort.to_h
uniqueNames.each {|k, v|
    if(v > 1) 
        puts "Duplicate names\tNumber"
        puts "#{k}\t#{v}"
    end
}
noOfUniqueNames = $uniqueNames.count
puts "\nNo of unique names: #{noOfUniqueNames}"
