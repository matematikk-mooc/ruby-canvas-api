require 'csv'
require "json"

nsr = JSON.parse(File.read('nsrskoler.json'))

grunnskoler = 0
grunnskoler_offentlige = 0
grunnskoler_private = 0
vgs = 0
vgs_offentlige = 0
vgs_private = 0
andre = 0

av_grunnskoler = 0
av_grunnskoler_offentlige = 0
av_grunnskoler_private = 0
av_vgs = 0
av_vgs_offentlige = 0
av_vgs_private = 0
av_andre = 0
nsr.each { |o|
    if(o["ErAktiv"])
        if(o["ErSkole"])
            if(o["ErGrunnSkole"]) 
                av_grunnskoler += 1
                if(o["ErPrivatSkole"])
                    av_grunnskoler_private += 1
                elsif(o["ErOffentligSkole"])
                    av_grunnskoler_offentlige += 1
                end
            elsif (o["ErVideregaaendeSkole"])
                av_vgs += 1
                if(o["ErPrivatSkole"])
                    av_vgs_private += 1
                elsif(o["ErOffentligSkole"])
                    av_vgs_offentlige += 1
                end
            end
        else 
            av_andre += 1
        end
    end
}
puts "av_grunnskoler:#{av_grunnskoler}"
puts "av_grunnskoler_offentlige:#{av_grunnskoler_offentlige}"
puts "av_grunnskoler_private:#{av_grunnskoler_private}"
puts "av_vgs:#{av_vgs}"
puts "av_vgs_offentlige:#{av_vgs_offentlige}"
puts "av_vgs_private:#{av_vgs_private}"
puts "av_andre:#{av_andre}"


#"NSRId": 0,
#"OrgNr": "string",
#"Navn": "string",
#"Karakteristikk": "string",
#"FulltNavn": "string",
#"KommuneNavn": "string",
#"Epost": "string",
#"ErAktiv": true,
#"ErSkole": true,
#"ErSkoleEier": true,
#"ErGrunnSkole": true,
#"ErPrivatSkole": true,
#"ErOffentligSkole": true,
#"ErVideregaaendeSkole": true,
#"VisesPaaWeb": true,
#"KommuneNr": "string",
#"FylkeNr": "string",
#"EndretDato": "2020-02-07T13:34:30.044Z"
CSV.foreach("kpasskoler.csv") do |row|
    print "."
    id,canvas_id,category_id,name,description,created_at,updated_at = row
    next if id == "id"
    nsrid = description.split(":")[3].to_i
    o = nsr.select{|a|a["NSRId"]==nsrid}[0]
    if(!o)
        puts "Could not find nsrid #{nsrid}"
    else 
        if(o["ErAktiv"])
            if(o["ErSkole"])
                if(o["ErGrunnSkole"]) 
                    grunnskoler += 1
                    if(o["ErPrivatSkole"])
                        grunnskoler_private += 1
                    elsif(o["ErOffentligSkole"])
                        grunnskoler_offentlige += 1
                    end
                elsif (o["ErVideregaaendeSkole"])
                    vgs += 1
                    if(o["ErPrivatSkole"])
                        vgs_private += 1
                    elsif(o["ErOffentligSkole"])
                        vgs_offentlige += 1
                    end
                end
            else 
                andre += 1
            end
        end
    end
end
puts "\nSkoletype\tAntall påmeldte\tAntall mulige"
puts "Grunnskoler\t#{grunnskoler}\t#{av_grunnskoler}\t"
puts "Offentlige grunnskoler\t#{grunnskoler_offentlige}\t#{av_grunnskoler_offentlige}"
puts "Private grunnskoler\t#{grunnskoler_private}\t#{av_grunnskoler_private}"
puts "Vgs\t#{vgs}\t#{av_vgs}"
puts "Offentlige vgs\t#{vgs_offentlige}\t#{av_vgs_offentlige}"
puts "Private vgs\t#{vgs_private}\t#{av_vgs_private}"
puts "Andre\t#{andre}\t#{av_andre}"
