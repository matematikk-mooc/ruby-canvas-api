require 'canvas-api'
require 'colorize'
require_relative 'connection'  
require_relative 'siktfunctions'

dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 1)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lister ut sider for kurs med id cid")
	exit
end


$canvas = getCanvasConnection(dst)
dbg($canvas)

def processPages(list)
    list.each { |c|
        printf("%s\t%s\t%s\n", c['url'], c['html_url'], c['title'])
    }
end

list = getPages(cid)
processPages(list)
while list.more?  do
  list = list.next_page!
processPages(list)
end
