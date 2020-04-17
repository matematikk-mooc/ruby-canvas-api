require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
require 'colorize'

if(ARGV.size < 3)
	dbg("Usage: ruby #{$0} prod/beta gid filename")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut gruppetilhørighet for gruppesettet 'gid' til fil.")
	exit
end
dst = ARGV[0]
gid = ARGV[1]
filename = ARGV[2]

def OpenFile(filename)
	return File.open( filename,"w:UTF-8" )
end
def CloseFile(file)
	file.close
end

def myputs(s)
	$file << s
end

canvas = getCanvasConnection(dst)
$file = OpenFile(filename)
$file.write "\uFEFF"

$groupIdHash = Hash.new
$schoolHash = Hash.new

$noOfGroups = 0
$noOfUniqueGroups = 0
$noOfUniqueNsrIdGroups = 0
#courseId:360:school:1006884:975277194
def processList(list)
    list.each { |c|
        $noOfGroups += 1
        groupId = c["id"]
        schoolName = c["name"]
        members = c["members_count"]

        if(!$groupIdHash.key?(groupId))
            $noOfUniqueGroups += 1
            c["api_return"] = 1
            $groupIdHash[groupId] = c

            parsed = c['description'].split(":")
            nsrid = parsed[3]
            orgNo = parsed[4]
        
            if(!$schoolHash.key?(nsrid))
                $noOfUniqueNsrIdGroups += 1
                $schoolHash[nsrid] = c
            else 
                newC = c
                prevC = $schoolHash[nsrid]
                if(prevC["created_at"] > c["created_at"]) 
                    newC = prevC
                    puts "Using group with #{newC['created_at']} creation date."
                end
                puts "DUPLICATE NSRID #{nsrid}:".red
                puts "Previous: #{prevC}".red 
                puts "Duplicate:#{c}".red
                puts "New:#{newC}".red
                prevCount = prevC["members_count"]
                currentCount = c["members_count"]
                newCount = prevCount + currentCount
                newC["members_count"] = newCount
                $schoolHash[nsrid] = newC
                puts "Previous member count: #{prevCount} current count: #{currentCount} Sum: #{newCount}".red
            end
    
        else 
            prevGroup = $groupIdHash[groupId]
            prevGroup["api_return"] += 1
            $groupIdHash[groupId] = prevGroup

            puts "WARNING: Group id #{groupId} returned again by API. Skipping.".red
            puts "Previous group:#{prevGroup}"
            puts "This group:#{c}"

        end

    } 
end

uri = sprintf("/api/v1/group_categories/%d/groups?per_page=50", gid)
list = canvas.get(uri)
myputs("Id;Navn;NSRid;Organisasjonsnummer;Deltagere\n")
#puts "List length: #{list.length}"
#puts list
processList(list)

while list.more?  do
    list = list.next_page!
#    puts list
#    puts "List length: #{list.length}"
    processList(list)
    print(".")
end

puts "NSRID"
$firstLine = true
myputs("[")

$schoolHash.each {|i, c|
    parsed = c['description'].split(":")
    nsrid = parsed[3]
    orgNo = parsed[4]
    puts nsrid

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
myputs("]")

def processList(list)
    list.each { |c|
    } 
end 

CloseFile($file)

puts "DUPLICATE GROUP IDS".red
$groupIdHash.each {|i, c|
    apiReturn = c["api_return"]
    if(apiReturn > 1)
        puts "#{i}\t#{apiReturn}"
    end
}
puts "Number of group ids: #{$noOfGroups}"
puts "Number of unique group ids: #{$noOfUniqueGroups}"
puts "Number of unique group nsrids: #{$noOfUniqueNsrIdGroups}"
