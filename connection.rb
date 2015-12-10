#Forfatter: Erlend Thune (erlend.thune@iktsenteret.no)
#Dato: Høsten 2015
#Skrevet i forbindelse med prosjektet matematikkMOOC
#https://github.com/whitmer/canvas-api
require 'canvas-api'

$prod = "https://matematikk.mooc.no"
$beta = "https://beta.matematikk.mooc.no"
def getCanvasConnection(dst)
	conn = nil;
	if(dst == "prod")
		conn = Canvas::API.new(:host => $prod, :token => "Vey7Yc0YExJ1lzFbFNyeAcaU5pstxFbibyAl6ir5ziUfql1az5LebWleUPlU4fkk")
	else
		conn = Canvas::API.new(:host => $beta, :token => "IcucDUlSU6JRlYJr0endPns6AdXkRDGnTzEXt3dyKqk0vaEVlRi2hAQkHhyfJDkn")
	end
	return conn;
end

