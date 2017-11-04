extends Object

var positions = {}

func _init():
	add(4, 0, 0x2)

func add(index, pitch, sound, note_bars):
	positions{index} = SongPosition.new(pitch, sound, note_bars)

class SongPosition:
	var pitch
	var sound
	var note_bars
	
	func _init(pitch, sound, note_bars):
		self.pitch = pitch
		self.sound = sound
		self.note_bars = note_bars