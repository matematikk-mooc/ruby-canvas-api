puts '<!doctype html>'
puts '<html lang="no">'
puts '<head>'
puts '<meta charset="UTF-8">'
puts '</head>'
puts '<body>'
puts '<h1>MatematikkMOOC statistikk</h1>'
puts '<p>Sjekk datoen i hver enkelt fil nedenfor for å se når den er blitt generert.</p>'


Dir.entries(".").select {|f| 
if !File.directory? f
	if File.extname(f) == ".html"  
		puts '<a href="'
		puts f
		puts '">'
		puts f
		puts '</a>'
		puts '<br/>'
	end
end
}

puts '</body>'
puts '</html>'