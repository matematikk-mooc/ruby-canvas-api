require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kopierer oppgaver til innholdssider i kurs med id cid.")
	exit
end


$canvas = getCanvasConnection(dst)

def convertAssignmentToPage(cid, mid, aid, position)
    a = getAssignment(cid, aid)
    body = a['description']
    title = a["name"]
    newPage = createPage(cid, title, body)
    createModuleItem(cid, mid, "Page", newPage, position)
    deleteAssignment(cid, aid)
end

modules = getModules(cid)
modules.each { |x| 
    mid = x["id"];
    moduleItems = getModuleItems(cid, mid)
    moduleItems.each { |y|
        if(y["type"] == "Assignment") 
            aid = y["content_id"]
            position = y["position"]
            convertAssignmentToPage(cid, mid, aid, position)
        end
    } 
}

