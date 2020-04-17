require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta gid filename")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kommandoen lister ut gruppetilhørighet for gruppesettet 'gid'.")
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
$communityidHash = Hash.new

$noOfUniqueGroups = 0
$noOfUniqueCommunityNoGroups = 0

#courseId:360:community:4206:964083266
def processList(list)
    list.each { |c|
        groupId = c["id"]
        if(!$groupIdHash.key?(groupId))
            $noOfUniqueGroups += 1
            $groupIdHash[groupId] = 1

            parsed = c['description'].split(":")
            communityid = parsed[3]
            
            if(!$communityidHash.key?(communityid))
                $noOfUniqueCommunityNoGroups += 1
                $communityidHash[communityid] = c
            else 
                newC = c
                prevC = $communityidHash[communityid]
                if(prevC["created_at"] > c["created_at"]) 
                    newC = prevC
                    puts "Using group with #{newC['created_at']} creation date."
                end
                puts "DUPLICATE communityid:".red
                puts "Previous: #{prevC}".red 
                puts "Duplicate:#{c}".red
                prevCount = prevC["members_count"]
                currentCount = c["members_count"]
                newCount = prevCount + currentCount
                newC["members_count"] = newCount
                $communityidHash[communityid] = newC
                puts "Previous member count: #{prevCount} current count: #{currentCount} Sum: #{newCount}".red
            end
    
        else 
            $groupIdHash[groupId] += 1
            n = $groupIdHash[groupId]
            puts "WARNING: Group id #{groupId} returned a #{n}. time by API. Skipping.".red
        end
    } 
end

uri = sprintf("/api/v1/group_categories/%d/groups?per_page=50", gid)
list = canvas.get(uri)
myputs("Id;Kommune;Kommunenummer;Organisasjonsnummer;Deltagere\n")

processList(list)
while list.more?  do
	list = list.next_page!
    processList(list)
    print(".")
end

$communityidHash.each {|i, c|
    parsed = c['description'].split(":")
    communityid = parsed[3]
    orgNo = parsed[4]
    myputs("#{c['id']};#{c['name']};#{communityid};#{orgNo};#{c['members_count']}\n")
}
CloseFile($file)

puts "DUPLICATE GROUP IDS".red
$groupIdHash.each {|i, c|
    if(c > 1)
        puts "#{i}\t#{c}"
    end
}
puts "Number of unique group ids: #{$noOfUniqueGroups}"
puts "Number of unique group nsrids: #{$noOfUniqueCommunityNoGroups}"


