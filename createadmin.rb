require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]
uid = ARGV[1]
aid = ARGV[2]

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta uid aid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Legger til bruker med user id uid som administrator til konto med kontoid aid.")
	exit
end


canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/accounts/%d/admins", aid)
newAdmin = canvas.post(uri, {'user_id' => uid, 'send_confirmation' => 0 })

print newAdmin

