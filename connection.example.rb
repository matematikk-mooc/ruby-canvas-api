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
		$token = ""
		$host = $prod
	else
	    $token = ""
		$host = $beta
	end
	puts $host
   	conn = Canvas::API.new(:host => $host, :token => $token)
	return conn;
end

