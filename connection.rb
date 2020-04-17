#Forfatter: Erlend Thune (erlend.thune@iktsenteret.no)
#Dato: Høsten 2015
#Skrevet i forbindelse med prosjektet matematikkMOOC
#https://github.com/whitmer/canvas-api
#require 'canvas-api'

#Erstatt prod og beta variablene med dine servere
$prod = "https://bibsys.instructure.com"
$beta = "https://bibsys.beta.instructure.com"
def getCanvasConnection(dst)
	conn = nil;
	if(dst == "prod")
		#Du må generere ditt eget token. Les hvordan her:
		#https://guides.instructure.com/m/4214/l/40399-how-do-i-obtain-an-api-access-token-for-an-account
		$token = "3727~MZFheA8yXbbxDiq5FuBGCtGgC3PFkx0croC4M2kCB1jcc3lMSbtfnlAgTloMoXNg"
		$host = $prod
	else
	    $token = "BTbf0P0ovlKRuUQbzD83Gmtz8V5hxe4PQ5ayMwKNnnR67Y2vuDneHl6ZY0WJXQex"
		$host = $beta
	end
	puts $host
   	conn = Canvas::API.new(:host => $host, :token => $token)
	return conn;
end

