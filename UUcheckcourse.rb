require 'canvas-api'
require 'colorize'
require_relative 'connection'  
require_relative 'siktfunctions'

dst = ARGV[0]
$cid = ARGV[1]
s = ARGV[2]

if(ARGV.size < 1)
	dbg("Usage: ruby #{$0} run")
	dbg("Søker etter innhold i mappen.")
	exit
end

$discussionType = 0
$assignmentType = 1
$quizType = 2
$pageType = 3

$canvas = getCanvasConnection(dst)
dbg($canvas)

def containsSubtitles(url)
	buffer = open(url).read
	if(buffer.include? "<error>") 
		return false
	end
	return true
end

puts "UU-kontroll"
puts "Sjekker innholdssider for vimeofilmer og underteksting"

i=0
kpasVideoUrls = []
Dir.foreach('.') do |filename|
	next if filename == '.' or filename == '..'
	# Do work on the remaining files & directories
	#puts filename
	i=i+1
	buffer = open(filename).read
	result = JSON.parse(buffer)
	html_url = result["html_url"]
	course_id = result["course_id"]
	urls = URI.extract(result["body"], /http(s)?/)
	urls.each do |url|
		match = url.match(/https?:\/\/(?:[\w]+\.)*vimeo\.com(?:[\/\w]*\/?)?\/(?<id>[0-9]+)[^\s]*/)
		if(match)
			id = match[:id]
			kpasurl = "https://kpas-lti.azurewebsites.net/api/vimeo/#{id}"
			if(!containsSubtitles(kpasurl)) 
				puts("Mangler underteksting i URL:#{html_url} VIMEOURL:#{url} SUBTITLESURL:#{kpasurl}")
				kpasVideoUrls.push(id)
			end
		end
	end
end
puts "No of files:#{i}"

kpasVideoUrls.each do |videoId|
	puts 'delete from subtitles where videoId="' + videoId +'";'
end

