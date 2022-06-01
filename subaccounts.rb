require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta accountid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lister ut underkontoene for accountid på serveren.")
	exit
end

accountid = ARGV[1]

def OpenFile(filename)
	return File.open( filename,"w:UTF-8" )
end
def CloseFile(file)
	file.close
end

def myputs(s)
	$file << s
end
$file = OpenFile("allcourses.csv")
$canvas = getCanvasConnection(dst)
printf("Id\Underkonto\n")


def processCourses(list)
	printf("Id\tKonto Id\tKursnavn\tAntall studenter\tFaglærere\n")

    list.each { |c|
        teachers = ""
        teacherArr = c["teachers"]
		teacherArr.each { |t| 
		  profile = getUserProfile(t["id"])
          teachers += t["display_name"] + " " + profile["primary_email"] + ","
        }
		printf("%s\t%s\t%s\t%s\n", c['id'], c['account_id'], c['name'], c['total_students'], teachers)
    } 
end

def listSubaccounts(accountid)
	uri = sprintf("/api/v1/accounts/%d/sub_accounts?per_page=999", accountid)

	list = $canvas.get(uri)
	list.each { |c|
		subaccountid = c['id']
		printf("%s\t%s\n", subaccountid, c['name'])
		courseList = getCourses(subaccountid)
		processCourses(courseList)
		listSubaccounts(subaccountid)
	} 
end
listSubaccounts(accountid)


