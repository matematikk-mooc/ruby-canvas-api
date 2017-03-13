#Forfatter: Erlend Thune (erlend.thune@iktsenteret.no)
#Dato: Høsten 2015
#Skrevet i forbindelse med prosjektet matematikkMOOC
#https://github.com/whitmer/canvas-api
require 'canvas-api'

#Erstatt prod og beta variablene med dine servere
$prod = "https://matematikk.mooc.no"
$beta = "https://beta-matematikk.mooc.no"
def getCanvasConnection(dst)
	conn = nil;
	if(dst == "prod")
		#Du må generere ditt eget token. Les hvordan her:
		#https://guides.instructure.com/m/4214/l/40399-how-do-i-obtain-an-api-access-token-for-an-account
		conn = Canvas::API.new(:host => $prod, :token => "Vey7Yc0YExJ1lzFbFNyeAcaU5pstxFbibyAl6ir5")
	else
		conn = Canvas::API.new(:host => $beta, :token => "oL61YvmG79Nne6GJZyn7PLaUOuksd2UaXhWx1hjJ")
	end
	return conn;
end

