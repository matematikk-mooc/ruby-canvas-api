require 'canvas-api'
require 'colorize'
require_relative 'connection'  
require_relative 'siktfunctions'

dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Laster ned innhold fra kurs med id cid og lagrer i filer.")
	exit
end

$canvas = getCanvasConnection(dst)
dbg($canvas)

puts "Leter i sider..."
list = getPages(cid)
download(cid, list, $pageType)
while list.more?  do
  list = list.next_page!
  download(cid, list, $pageType)
end

