extends Node2D

onready var main = get_node("Main")

onready var song_seq = get_node("/root/Mainroot/SongSequencer")
onready var note_player = get_node("/root/Mainroot/NotePlayer")
onready var piano_player = get_node("/root/Mainroot/PianoPlayer")
onready var chord_player = get_node("/root/Mainroot/ChordPlayer")
onready var class_song_reader = load("res://classes/SongReader.gd")
onready var demo_song_resource = load("res://songs/DemoSong.gd")
onready var song = load("res://classes/Song.gd")
onready var single_bar = load("res://scenes/note.tscn")
onready var bar_begin = load("res://scenes/bar_begin.tscn")
onready var bar_held = load("res://scenes/bar_held.tscn")
onready var bar_end = load("res://scenes/bar_end.tscn")

onready var song_selector = get_node("/root/song_selector")

var song_path = "res://songs/DemoSong1.csv"

var color_array = [Color(1,0,0), Color(1,1,0), Color(0,0,1), Color(0,1,0)]

var note_bars = []
var note_bar_pos = []

var base_pos = Vector2(-450,-185)
var x_offset = Vector2(192,0)
var y_offset = Vector2(0,102)

var x_int_offset = 2

func _ready():
	set_process(true)
	
	song_path = song_selector.song_path

	var song_reader = class_song_reader.new()
	
	song_seq.initialize(note_player, piano_player, chord_player, song_reader.read_song(song_path, chord_player.get_max_chord_size()))

func _process(delta):
	var changed = song_seq.advance(delta*1000)
	
	var note_array = song_seq.get_current_notes(-x_int_offset, 7)
	var offset = song_seq.get_current_offset()
	
	if changed and changed>=1:
		
		for note_bar in note_bars:
			note_bar.queue_free()
		
		note_bars = []
		note_bar_pos = []
		
		for i in range(note_array.size()):
			if note_array[i]==null:
				pass
			else:
				var color_index = note_array[i].color
				for j in range(note_array[i].buttons.size()):
						if note_array[i].buttons[j] == song.NoteType.Single:
							print("single")
							var bar = single_bar.instance()
							add_child(bar)
							var pos = base_pos + (i-x_int_offset)*x_offset + (3-j) * y_offset
							bar.set_position(pos)
							note_bars += [bar]
							note_bar_pos += [pos]
							bar.get_child(0).set_modulate(color_array[color_index])
						elif note_array[i].buttons[j] == song.NoteType.Pressed:
							print("pressed")
							var bar = bar_begin.instance()
							add_child(bar)
							var pos = base_pos + (i-x_int_offset)*x_offset + (3-j) * y_offset
							bar.set_position(pos)
							note_bars += [bar]
							note_bar_pos += [pos]
							bar.get_child(0).set_modulate(color_array[color_index])
						elif note_array[i].buttons[j] == song.NoteType.Held:
							print("held")
							var bar = bar_held.instance()
							add_child(bar)
							var pos = base_pos + (i-x_int_offset)*x_offset + (3-j) * y_offset
							bar.set_position(pos)
							note_bars += [bar]
							note_bar_pos += [pos]
							bar.get_child(0).set_modulate(color_array[color_index])
						elif note_array[i].buttons[j] == song.NoteType.Released:
							print("released")
							var bar = bar_end.instance()
							add_child(bar)
							var pos = base_pos + (i-x_int_offset)*x_offset + (3-j) * y_offset
							bar.set_position(pos)
							note_bars += [bar]
							note_bar_pos += [pos]
							bar.get_child(0).set_modulate(color_array[color_index])
	for i in range(note_bars.size()):
		note_bars[i].set_position(note_bar_pos[i] - x_offset * (offset-1))

func _input(event):
	for i in range(0, 4):
		if event.is_action_pressed("play_tone" + str(i)):
			song_seq.set_button_state(i, true)
	for i in range(0, 4):
		if event.is_action_pressed("play_sound" + str(i)):
			song_seq.set_sound_state(i, true)
			pass
			
	for i in range(0, 4):
		if event.is_action_released("play_tone" + str(i)):
			song_seq.set_button_state(i, false)
	for i in range(0, 4):
		if event.is_action_released("play_sound" + str(i)):
			song_seq.set_sound_state(i, false)
			pass