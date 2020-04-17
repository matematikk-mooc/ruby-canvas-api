require 'csv'
require 'json'
file = File.read('nsrenheter.json')
data_hash = JSON.parse(file)
#data_hash.select{|o|o["NSRId"]==1008239}

file2 = File.read('skoler.json')
data_hash2 = JSON.parse(file2)
#data_hash2.select{|o|o["id"]==6037}

puts "\uFEFF"
keysWritten = false
data_hash2.each {|a|
    #puts "A"
    #puts a
    #puts a["NSRId"]
    b = data_hash.select{|o| o["NSRId"]==a["NSRId"].to_i}
    #puts "B"
    #puts b
    c=a.to_h
    d=b[0].to_h
    #puts "C"
    #puts c
    #puts "D"
    #puts d
    e=c.merge(d)
    #puts e
    #exit
    if(!keysWritten)
        csv_string = CSV.generate do |csv|
            csv << e.keys
        end
        puts csv_string            
        keysWritten = true
    end

    csv_string = CSV.generate do |csv|
        csv << e.values
    end
    puts csv_string   
}

