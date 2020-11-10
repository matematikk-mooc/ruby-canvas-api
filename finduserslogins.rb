require 'csv'
require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta inputfile filename")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Henter ut logins for brukerne i inputfile og lagrer de i fil med filename.")
	exit
end

dst = ARGV[0]
inputfile =  ARGV[1]
filename = ARGV[2]

$canvas = getCanvasConnection(dst)
$rows = []


$csv = CSV.open(filename, "wb")

puts "Input file: " + inputfile
#mapping = CSV.read(inputfile, {:col_sep => ";"})

users = CSV.open(inputfile, headers: :first_row).map(&:to_h)


def processList(list)
    list.each { |h|
        $csv << h.values
    } 
end



$stdout.sync = true

print "Getting users..."
i=0
users.each { |u| 
    puts i
    i=i+1
    #puts u
    uri = sprintf("/api/v1/users/%d/logins", u["id"]);      
    puts uri;
    list = $canvas.get(uri)
    processList(list)
    while list.more?  do
        list = list.next_page!
        print "."
        processList(list)
    end
}




