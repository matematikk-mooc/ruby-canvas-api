require 'canvas-api'
require_relative 'connection' 
require_relative 'siktfunctions' 
dst = ARGV[0]
cid = ARGV[1]

if(ARGV.size < 2)
	dbg("Usage: ruby #{$0} prod/beta cid")
	dbg("prod/beta angir om kommandoene skal kjøres mot henholdsvis #{$prod} eller #{$beta}")
	dbg("Kopierer diskusjoner til innholdssider i kurs med id cid.")
	exit
end


$canvas = getCanvasConnection(dst)

def convertDiscussionToPage(cid, mid, did, position)
    d = getDiscussion(cid, did)
    body = d['message']
    title = d["title"]
    newPage = createPage(cid, title, body)
    createModuleItem(cid, mid, "Page", newPage, position)
    deleteDiscussion(cid, did)
end

modules = getModules(cid)
modules.each { |x| 
    mid = x["id"];
    moduleItems = getModuleItems(cid, mid)
    moduleItems.each { |y|
        if(y["type"] == "Discussion") 
            did = y["content_id"]
            position = y["position"]
            convertDiscussionToPage(cid, mid, did, position)
        end
    } 
}

