require 'canvas-api'
require 'colorize'
require_relative 'connection'  
require_relative 'siktfunctions'

dst = ARGV[0]
$cid = ARGV[1]
s = ARGV[2]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid innhold")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Søker etter innhold i kurs med id cid")
	exit
end

$discussionType = 0
$assignmentType = 1
$quizType = 2
$pageType = 3

$canvas = getCanvasConnection(dst)
dbg($canvas)

def searchFor(list, type, s)
	list.each { |c|
	    puts  c['title']
		key = c["url"]
		body = ""
		if(type == $pageType)
            body = getPageData($cid, c['url'])
		elsif (type == $discussionType)
            body = c['message']
		elsif (type == $assignmentType)
            body = c['description']
		elsif (type == $quizType)
            body = c['description']
		end
    #	puts body
        if body
            if body.downcase.include? s.downcase
                puts("\n================")
                puts"FOUND".black.on_yellow
                printf("%s\t%s\n", c['title'], c['html_url'])
                puts("================")
            end
        end	
	} 
end

puts "================"
puts "================"
puts "================"

puts "Leter i sider..."
list = getPages($cid)
searchFor(list, $pageType, s)

puts "================"
puts "================"
puts "================"
puts "Leter i diskusjoner..."
list = getDiscussions($cid)
searchFor(list, $discussionType, s)

puts "================"
puts "================"
puts "================"
puts "Leter i oppgaver..."
list = getAssignments($cid)
searchFor(list, $assignmentType, s)

puts "================"
puts "================"
puts "================"
puts "Leter i quizer..."
list = getQuizzes($cid)
searchFor(list, $quizType, s)

