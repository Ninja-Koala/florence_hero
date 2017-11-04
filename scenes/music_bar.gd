extends Node2D

onready var song_seq = $SongSequencer
onready var note_player = $NotePlayer
onready var demo_song_resource = load("res://songs/DemoSong.gd")
onready var song = load("res://classes/Song.gd")
onready var note_bar = load("res://scenes/note.tscn")

var note_bars = []
var note_bar_pos = []

var base_pos = Vector2(-280,-150)
var x_offset = Vector2(192,0)
var y_offset = Vector2(0,102)

func _ready():
	set_process(true)
	song_seq.initialize(note_player, demo_song_resource.new())

func _process(delta):
	var changed = song_seq.advance(delta*1000)
	
	var note_array = song_seq.get_current_notes(4)
	var offset = song_seq.get_current_offset()
	
	if changed and changed>=1:
		
		for note_bar in note_bars:
			note_bar.queue_free()
		
		note_bars = []
		note_bar_pos = []
		
		for i in range(4):
			for j in range(4):
					if note_array[i][j] == song.NoteType.Single:
						var bar = note_bar.instance()
						add_child(bar)
						var pos = base_pos + i*x_offset + (3-j) * y_offset
						bar.set_position(pos)
						note_bars += [bar]
						note_bar_pos += [pos]
	for i in range(note_bars.size()):
		note_bars[i].set_position(note_bar_pos[i] - x_offset * (offset-1))