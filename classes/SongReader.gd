extends Object

var class_song = load("res://classes/Song.gd")

func read_song(path):
	var file = File.new()
	file.open(path, file.READ)
	var result = class_song.new()
	
	#read captions
	var captions = file.get_csv_line(";")
	while !file.eof_reached():
		var line = file.get_csv_line(";")
		
		#elements must have size 8
		if line.size() != 8:
			break
		
		var elements = [line[0], line[1], line[2], line[3], line[4], line[5], line[6], line[7]]
		
		#special characters
		if elements[0] == "":
			elements[0] = 0
			elements[1] = -1
		elif elements[0] == "x":
			elements[0] = 0
			elements[1] = -1
		
		result.add_note(int(elements[0]), int(elements[1]), int(elements[2]), int(elements[3]), int(elements[4]), int(elements[5]), int(elements[6]), elements[7])
		
	file.close()
	print(result.get_length())
	return result