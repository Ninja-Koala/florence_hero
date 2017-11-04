extends Object

var positions = []

func _init():
	pass

func get_length():
	return positions.size()

func add(pitch, sound, note_bars):
	positions.push_back(SongPosition.new(pitch, sound, note_bars))

func add_pause(count):
	for i in range(0, count):
		positions.push_back(null)

func play_notes_at(player, index):
	var position = positions[index]
	if position == null:
		return
	player.stop()
	player.play(position.pitch, position.sound)

func get_notes_in_range(index, count):
	var result = []
	for i in range(0, count):
		var position
		if i < positions.size():
			 position = positions[index + i]
		
		var notes = [NoteType.None, NoteType.None, NoteType.None, NoteType.None]
			
		if position != null:
			if position.note_bars & 1 != 0:
				notes[0] = Single
			if position.note_bars & 2 != 0:
				notes[1] = Single
			if position.note_bars & 4 != 0:
				notes[2] = Single
			if position.note_bars & 8 != 0:
				notes[3] = Single
			
		result.push_back(notes)
	return result

class SongPosition:
	var pitch
	var sound
	var note_bars
	
	func _init(pitch, sound, note_bars):
		self.pitch = pitch
		self.sound = sound
		self.note_bars = note_bars

enum NoteType {
	None,
	Single,
	Pressed,
	Held,
	Released
}