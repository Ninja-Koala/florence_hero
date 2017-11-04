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
		var position = positions[index + i]
		if position != null:
			result.push_back(position.note_bars)
		else:
			result.push_back(0)

class SongPosition:
	var pitch
	var sound
	var note_bars
	
	func _init(pitch, sound, note_bars):
		self.pitch = pitch
		self.sound = sound
		self.note_bars = note_bars