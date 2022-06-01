require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta accountid [sis]")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Lister ut kursene på serveren for konto accountid.")
	dbg("Hvis sis er med som siste parameter blir innholdet listet ut på en måte som egner seg for sis import.")
	dbg("Dette kan f.eks. være nyttig hvis man ønsker å opprette kursene på en annen server.")
	dbg("Ved sis utskrift blir kurset satt til aktivt uavhenig av hva status på kurset er, og bare de obligatoriske")
	dbg("sis parameterne blir satt") 
	exit
end

dst = ARGV[0]
accountId = ARGV[1]
frmt = ARGV[2]

$canvas = getCanvasConnection(dst)

def OpenFile(filename)
	return File.open( filename,"w:UTF-8" )
end
def CloseFile(file)
	file.close
end

def myputs(s)
	$file << s
end

$file = OpenFile("courses.csv")
if(frmt == "sis")
  printf("course_id,short_name,long_name,account_id,term_id,status,start_date,end_date,course_format\n")
else
    myputs("EmneId;KontoId;KursNavn;AntallStudenter;Faglærere;FaglærereEpost\n")
end


def processCourses(list, frmt)
    list.each { |c|
        puts c
        puts("Kursid:#{c['id']} KontoId:#{c['account_id']}")
        teachers = ""
        teachersEmail = ""
        teacherArr = c["teachers"]
        firstEntry = true
        teacherArr.each { |t| 
          if(!firstEntry)
            teachers += ", "
          end
          if(!firstEntry)
            teachersEmail += ", "
          end
          #puts("ProfilId:#{t['id']}")
          profile = getUserProfile(t["id"])
          if(profile != nil)
            teachers += t["display_name"]
            if(profile["primary_email"])
              teachersEmail += profile["primary_email"]
            end
          end
          firstEntry = false
        }
       if(frmt == "sis")
            printf("%s,%s,%s,,,active,,,\n",c['sis_course_id'],c['course_code'],c['name'])
        else
            myputs("#{c['id']};#{c['account_id']};#{c['name']};#{c['total_students']};#{teachers};#{teachersEmail}\n")
        end
    } 

end


list = getCourses(accountId)
processCourses(list, frmt)
while list.more?  do
  list = list.next_page!
  processCourses(list, frmt)
end

CloseFile($file)