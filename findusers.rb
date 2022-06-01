require 'csv'
require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta aid filename")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Henter ut brukere på JSON format fra konto med id aid og lagrer de som csv i fil med filename.")
	exit
end

dst = ARGV[0]
accountid = ARGV[1]
filename = ARGV[2]

$canvas = getCanvasConnection(dst)
$rows = []


$csv = CSV.open(filename, "wb")


def processList(list)
    list.each { |h|
        $csv << h.values
    } 
end


uri = sprintf("/api/v1/accounts/%d/users", accountid)

$stdout.sync = true

print "Getting users..."
list = $canvas.get(uri)
column_names = list.first.keys
$csv << column_names
processList(list)
while list.more?  do
  list = list.next_page!
  print "."
  processList(list)
end



