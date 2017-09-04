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
accountid = ARGV[1]
frmt = ARGV[2]

canvas = getCanvasConnection(dst)

uri = sprintf("/api/v1/accounts/%d/courses?per_page=999", accountid)

def processCourses(list, frmt)
if(frmt == "sis")
  printf("course_id,short_name,long_name,account_id,term_id,status,start_date,end_date,course_format\n")
else
    printf("Id\tKursnavn\n")
end

list.each { |c|
    if(frmt == "sis")
        printf("%s,%s,%s,,,active,,,\n",c['sis_course_id'],c['course_code'],c['name'])
    else
    	printf("%s\t%s\n", c['id'], c['name'])
	end
} 

end


list = canvas.get(uri)
processCourses(list, frmt)
while list.more?  do
  list = list.next_page!
  processCourses(list, frmt)
end
#SIS FORMAT from https://canvas.instructure.com/doc/api/file.sis_csv.html
#Field Name	Data Type	Required	Sticky	Description
#course_id	text	✓		A unique identifier used to reference courses in the enrollments data. This identifier must not change for the account, and must be globally unique. In the user interface, this is called the SIS ID.
#short_name	text	✓	✓	A short name for the course
#long_name	text	✓	✓	A long name for the course. (This can be the same as the short name, but if both are available, it will provide a better user experience to provide both.)
#account_id	text			The account identifier from accounts.csv, if none is specified the course will be attached to the root account
#term_id	text		✓	The term identifier from terms.csv, if no term_id is specified the default term for the account will be used
#status	enum	✓	✓	active, deleted, completed
#start_date	date		✓	The course start date. The format should be in ISO 8601: YYYY-MM-DDTHH:MM:SSZ
#end_date	date		✓	The course end date. The format should be in ISO 8601: YYYY-MM-DDTHH:MM:SSZ
#course_format	enum			on_campus, online, blended