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

$stats = Hash.new
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
        $sofar+=1
        cat = e["created_at"];
        if($stats.key?(cat))
            $stats[cat] += 1
        else
            $stats[cat] = 1
        end
    } 
end
$file2 = OpenFile("enrollments#{courseId}.csv")
$sofar = 0
page = 1
puts "page #{page}"
list = getEnrollmentsForCourse(courseId)
processEnrollments(list)
page += 1

while list.more?  do
  puts "page #{page} - #{$sofar}"
  list = list.next_page!
  processEnrollments(list)
  page += 1
end

puts "Processing dates"
total = 0
pd = 0
d=0
first = true
statsSorted = $stats.sort.to_h
statsSorted.each {|k, v|
    d = k.split("T").first
    total += v
    if(first)
        first = false
        pd = d
    end
    if(d != pd)
        myputs($file2, "#{d}\t#{total}\n")
        pd = d
    end
}
myputs($file2, "#{d}\t#{total}\n")

CloseFile($file2)
