#https://github.com/whitmer/canvas-api
require 'canvas-api'
require_relative 'connection'  
require_relative 'siktfunctions' 
require_relative 'SiktUtility' 

dst = ARGV[0]
cid = ARGV[1]
$match = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta cid match")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen sletter seksjoner for kurs med kurs id 'cid' der seksjonsnavnet inneholder match.")
	exit
end

$canvas = getCanvasConnection(dst)

def processSection(section)
  puts("\n");
  puts(section["name"]);
  if section["name"].include? $match
  	uri = sprintf("/api/v1/sections/%d", section["id"])
	  result = $canvas.delete(uri)
  	puts(result);
  end
end

def processSections(sections)
	sections.each { |section| 
		processSection(section)
	}
end


uri = sprintf("/api/v1/courses/%d/sections",cid)
list = $canvas.get(uri)

processSections(list)
while list.more?  do
  list = list.next_page!
  processSections(list)
end

printf("Id\Section name\n")
list.each { |c|
	printf("%s\t%s\n", c['id'], c['name'])
} 

