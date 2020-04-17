require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta gid filename")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen skrive gruppene for gruppesettet 'gid' til filename.")
	exit
end
dst = ARGV[0]
gid = ARGV[1]
filename = ARGV[2]
canvas = getCanvasConnection(dst)


def OpenFile(filename)
	$file = File.open( filename,"w" )
end
def CloseFile()
	$file.close
end

def myputs(s)
	$file << s
end

OpenFile(filename)

#["courseId", "360", "school", "1027798", "921594038"] 
$firstLine = true
def processList(list)
    list.each { |c|
        if($firstLine)
            $firstLine = false
        else
            myputs(",")
        end
        d=c["description"].split(":")
        c["NSRId"] = d[3]
        c["OrgNr"] =d[4]
        myputs(c.to_json)
    } 
end    

uri = sprintf("/api/v1/group_categories/%d/groups", gid)

myputs("[")

list = canvas.get(uri)
processList(list)
while list.more?  do
  list = list.next_page!
  processList(list)
end
myputs("]")

CloseFile()


