extends Node

var ms_per_tick = 200
var ticks_per_note = 5
var before_tolerance = 1
var after_tolerance = 1

var player
var song

var current_ms = 0

func initialize(player, song):
	self.player = player
	self.song = song

func advance(ms):
	#calculate position before and after the advancement
	var tick_before = current_tick()
	current_ms += int(ms)
	var tick = current_tick()
	
	#has the song not advanced?
	if tick <= tick_before:
		return
		
	#is the song finished?
	if tick >= song.get_length():
		player.stop()
		return
	
	#play the tick
	song.play_notes_at(player, tick)

func get_current_noted(var count):
	return song.get_notes_in_range(current_tick(), count)

func current_tick():
	return current_ms / ms_per_tick

func get_score(var buttons):
	var notes = song.get_notes_in_range(current_tick())[0]
	return notes == buttons