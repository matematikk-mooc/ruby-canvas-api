#Forfatter: Erlend Thune (erlend.thune@iktsenteret.no)
#Dato: Høsten 2015
#Skrevet i forbindelse med prosjektet matematikkMOOC

require 'canvas-api'
require 'csv'
require_relative 'connection' 
require_relative 'SiktUtility2' 
require_relative "siktfunctions"

dst = ARGV[0] 
cid = ARGV[1]

#Opprett Canvasforbindelse. Dette gjøres i connection.rb
$canvas = getCanvasConnection(dst)


#Opprett seksjonshasher, en for studenter og en for lærere.
SiktUtility.populateSectionHash(cid)

def printEnrollmentsInSection(sid)
	#Print ut medlemmene i studentseksjonshashen
	array = SiktUtility.sectionStudentHash[sid]
	array.each { |x| 
		puts("#{x}\n")
	}

	array = SiktUtility.sectionTeacherHash[sid]
	array.each { |x| 
		puts("#{x}\n")
	}
end

puts("Seksjon 21")
printEnrollmentsInSection("21")

puts("Seksjon 22")
printEnrollmentsInSection("22")

puts("Seksjon 25")
printEnrollmentsInSection("25")
