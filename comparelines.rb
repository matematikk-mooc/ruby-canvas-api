#!/usr/bin/ruby

# script to compare and see what lines are in file1 but not file2

if(ARGV.size < 2)
    puts "Usage: #{$0} file1 file2"
    puts "Compare file1 and file2 and print out the lines that do not exist in file2."
    exit
end

filename1 = ARGV[0]
filename2 = ARGV[1]

f1 = File.open(filename1)
f2 = File.open(filename2)

file1lines = f1.readlines
file2lines = f2.readlines

file1lines.each do |e|
  if(!file2lines.include?(e))
    puts e
  end
end