require 'canvas-api'
require 'colorize'
require_relative 'connection'  
require_relative 'siktfunctions'

dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 1)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Liste ut innhold i en side")
	exit
end


$canvas = getCanvasConnection(dst)
dbg($canvas)

body = getPageData(cid, "1-dot-2-micro-bit%60s-sin-oppbygging")
print body