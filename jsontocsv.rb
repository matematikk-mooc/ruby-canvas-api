require 'csv'
require 'json'


if(ARGV.size < 2)
	puts("Usage: ruby #{$0} jsonfileName csvfileName")
	puts("Konverterer jsonfile til csvfile.")
	exit
end
jsonFileName = ARGV[0]
csvFileName = ARGV[1]

jsonFile = File.read(jsonFileName)
data_hash = JSON.parse(jsonFile)

def OpenFile(filename)
	$file = File.open( filename,"w" )
end
def CloseFile()
	$file.close
end

def myputs(s)
	$file << s
end

OpenFile(csvFileName)

myputs("\uFEFF")
keysWritten = false
data_hash.each {|a|
    if(!keysWritten)
        csv_string = CSV.generate do |csv|
            csv << a.keys
        end
        myputs(csv_string)
        keysWritten = true
    end

    csv_string = CSV.generate do |csv|
        csv << a.values
    end
    myputs(csv_string)
}

CloseFile()

