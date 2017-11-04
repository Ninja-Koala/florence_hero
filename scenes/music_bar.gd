extends Node2D

onready var song_seq = $SongSequencer
onready var note_player = $NotePlayer
onready var demo_song_resource = load("res://songs/DemoSong.gd")

func _ready():
	song_seq.initialize(note_player, demo_song_resource.new())
	
