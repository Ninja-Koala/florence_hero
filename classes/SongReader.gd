extends Object

const BASE_NOTES = {
	"C": 0,
	"C#": 1,
	"Db": 1,
	"D": 2,
	"D#": 3,
	"Eb": 3,
	"E": 4,
	"F": 5,
	"F#": 6,
	"Gb": 6,
	"G": 7,
	"G#": 8,
	"Ab": 8,
	"A": 9,
	"A#": 10,
	"Bb": 10,
	"Hb": 10,
	"B": 11,
	"H": 11
}

const CENTER_NOTE = 4

var class_song = load("res://classes/Song.gd")

func read_song(path, max_chord_size):
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
		elif elements[8].length() > 0 && elements[8][0] == "#":
			var chord_notes = elements[8].substr(1, elements[8].length() - 1).split(",")
			elements[8] = []
			for chord_note in chord_notes:
				elements[8].push_back(int(chord_note))
		else:
			elements[8] = get_chord(elements[8], max_chord_size)
			print(elements[8])
		
		result.add_note(int(elements[0]), int(elements[1]), int(elements[2]), int(elements[3]), int(elements[4]), int(elements[5]), int(elements[6]), elements[7], elements[8])
		
	file.close()
	result.add_pause(4)
	print(result.get_length())
	return result

func get_chord(name, max_note_count):
	var result = []
	if result.size() >= max_note_count:
		return result
	
	#base (and propably bass) note
	var base_note_name = get_note_by_name(name)
	var chord_type_name = name.substr(base_note_name.length(), name.length() - base_note_name.length())
	var base_note = BASE_NOTES[base_note_name]
	var bass_note = base_note
	
	#does the chord have a different base note?
	var slash_index = name.find("/")
	if slash_index >= 0:
		var bass = name.substr(slash_index + 1, name.length() - slash_index - 1)
		var bass_note_name = get_note_by_name(bass)
		bass_note = BASE_NOTES[bass_note_name]
	
	#add bass note
	result.push_back(center_note(bass_note))
	if result.size() >= max_note_count:
		return result
	
	#add fifth
	var fifth = base_note + 7
	result.push_back(center_note(fifth))
	if result.size() >= max_note_count:
		return result
	
	#minor chord?
	var third
	if chord_type_name != "" && chord_type_name[0] == "m":
		#add minor third
		third = base_note + 3
		chord_type_name = chord_type_name.substr(1, chord_type_name.length() - 1)
	else:
		#add major third
		third = base_note + 4
	
	#add third
	result.push_back(center_note(third))
	if result.size() >= max_note_count:
		return result
	
	#6th chord?
	if chord_type_name != "" && chord_type_name[0] == "6":
		#add 6th
		chord_type_name = chord_type_name.substr(1, chord_type_name.length() - 1)
		var sixth = base_note + 9
		result.push_back(center_note(sixth))
		if result.size() >= max_note_count:
			return result
	
	#7th chord?
	if chord_type_name != "" && chord_type_name[0] == "7":
		#add 7th
		chord_type_name = chord_type_name.substr(1, chord_type_name.length() - 1)
		var seventh = base_note + 10
		result.push_back(center_note(seventh))
		if result.size() >= max_note_count:
			return result
	
	return result

func get_note_by_name(name):
	var note_name = name[0]
	if name.length() >= 2 && (name[1] == "#" || name[1] == "b"):
			note_name += name[1]
	return note_name

func center_note(note):
	var diff = get_distance_from_center(note)
	var diff_up = get_distance_from_center(note + 12)
	var diff_down = get_distance_from_center(note - 12)
	
	if diff <= diff_up:
		if diff <= diff_down:
			return note
		else:
			return note - 12
	else:
		if diff_up <= diff_down:
			return note + 12
		else:
			return note - 12
	
func get_distance_from_center(note):
	if note < CENTER_NOTE:
		return CENTER_NOTE - note
	else:
		return note - CENTER_NOTE