require 'canvas-api'
require 'csv'
require_relative 'connection' 
require_relative 'SiktUtility' 
require_relative 'siktfunctions'
dst = ARGV[0] 
cid = ARGV[1]
gid = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid gid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen oppretter csv-fil videorommedlemskap for kurset med kurs id 'cid' og gruppesett 'gid'.")
	dbg("Denne filen kan så brukes som input i FEIDE connect.")
	dbg("Gruppene får samme medlemskap som seksjonene for studenter og lærere.")
	dbg("Seksjonene må eksistere og navnene må begynne med '#{SiktUtility.sectionPrefix}'.")
	exit
end

dbg(ARGV.size)
$canvas = getCanvasConnection(dst)

$filename = "acvideorommedlemskap.csv"
$acfile = File.open($filename,"w" )


def acputs(s)
	$acfile << s
end

def addMembersToAcFile(aHash)
	aHash.each do |sectionNo, array|
    groupId = SiktUtility.groupsHash[sectionNo]
    array.each { |x| 
	   acputs("#{groupId},#{x}\n")
	}
	end
end

#Opprett en hash med alle gruppene i gruppesettet gid.
SiktUtility.populateGroupsHash(gid)
SiktUtility.groupsHash.each do |key, id|
  dbg("#{key} #{id}")
end
	
#Populer en hash av seksjoner med studenter og lærere 
SiktUtility.populateSectionHash(cid)
dbg("Students")
SiktUtility.sectionStudentHash.each do |key, array|
  puts "#{key}-----"
  puts array
end
dbg("Teachers")
SiktUtility.sectionTeacherHash.each do |key, array|
  puts "#{key}-----"
  puts array
end

addMembersToAcFile(SiktUtility.sectionStudentHash)
addMembersToAcFile(SiktUtility.sectionTeacherHash)

$acfile.close

puts "AC input file:"
puts $filename
