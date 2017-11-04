extends Object

var positions = []

func _init():
	pass

func get_length():
	return positions.size()

func add(pitch, sound, note_bars):
	var button0 = int(note_bars & 1 != 0)
	var button1 = int(note_bars & 2 != 0)
	var button2 = int(note_bars & 4 != 0)
	var button3 = int(note_bars & 8 != 0)
	
	positions.push_back(SongPosition.new(pitch, sound, button0, button1, button2, button3, 0, null))

func add_note(pitch, sound, button0, button1, button2, button3, color, stage_direction):
	if sound == -1 && button0 == 0 && button1 == 0 && button2 == 0 && button3 == 0 && stage_direction == null:
		positions.push_back(null)
	else:
		positions.push_back(SongPosition.new(pitch, sound, button0, button1, button2, button3, color, stage_direction))

func add_pause(count):
	for i in range(0, count):
		positions.push_back(null)

func play_notes_at(player, index):
	var position = positions[index]
	if position == null || position.sound == -1:
		return
	player.stop()
	player.play(position.pitch, position.sound)

func get_entry_at(index):
	return positions[index]

func get_notes_in_range(index, count):
	var result = []
	for i in range(0, count):
		var position
		if index + i < positions.size():
			 position = positions[index + i]
			
		if position != null:
			result.push_back(position)
		else:
			result.push_back(null)
		
	return result

class SongPosition:
	var pitch
	var sound
	var buttons = [NoteType.None, NoteType.None, NoteType.None, NoteType.None]
	var color
	var stage_direction
	
	func _init(pitch, sound, button0, button1, button2, button3, color, stage_direction):
		self.pitch = pitch
		self.sound = sound
		self.buttons[0] = button0
		self.buttons[1] = button1
		self.buttons[2] = button2
		self.buttons[3] = button3
		self.color = color
		self.stage_direction = stage_direction

enum NoteType {
	None,
	Single,
	Pressed,
	Held,
	Released
}