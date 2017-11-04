extends Object

var class_song = load("res://classes/Song.gd")

func read_song(path):
	var file = File.new()
	file.open(path, file.READ)
	var result = class_song.new()
	
	while !file.eof_reached():
		var elements = file.get_csv_line(";")
		
		#elements must have size 6
		if elements.size() != 6:
			break
		
		#special characters
		if elements[0] == " ":
			elements[0] = 0
			elements[1] = -2
		elif elements[0] == "x":
			elements[0] = 0
			elements[1] = -1
		
		result.add_note(int(elements[0]), int(elements[1]), int(elements[2]), int(elements[3]), int(elements[4]), int(elements[5]))
		
	file.close()
	print(result.get_length())
	return result