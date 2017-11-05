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
		
		#elements must have size 9
		if line.size() != 9:
			break
		
		var elements = [line[0], line[1], line[2], line[3], line[4], line[5], line[6], line[7], line[8]]
		
		#special characters
		if elements[1] == "":
			elements[0] = "0"
			elements[1] = "-1"
		if elements[1] == "x":
			elements[0] = "0"
			elements[1] = "-2"
		
		#empty stage directions
		if elements[7] == "":
			elements[7] = null
		
		#chords
		if elements[8] == "":
			elements[8] = null
		elif elements[8] == "x":
			elements[8] = []
		else:
			var chord_notes = elements[8].split(",")
			elements[8] = []
			for chord_note in chord_notes:
				elements[8].push_back(int(chord_note))
		
		result.add_note(int(elements[0]), int(elements[1]), int(elements[2]), int(elements[3]), int(elements[4]), int(elements[5]), int(elements[6]), elements[7], elements[8])
		
	file.close()
	result.add_pause(4)
	print(result.get_length())
	return result