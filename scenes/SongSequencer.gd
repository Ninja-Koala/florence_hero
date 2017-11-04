extends Node

var ticks_per_note = 5
var before_tolerance = 1
var after_tolerance = 1

var song = [4, -1, 4, -1, 5, -1, 7, -1, 7, -1, 5, -1, 4, -1, 2, -1, 0, -1, 0, -1, 2, -1, 4, -1, 4, -1, -1, 2, 2, -1, -1, -2,     4, -1, 4, -1, 5, -1, 7, -1, 7, -1, 5, -1, 4, -1, 2, -1, 0, -1, 0, -1, 2, -1, 4, -1, 2, -1, -1, 0, 0, -1]

var current_tick = 0
var current_tick_played = false

func set_current_tick(tick):
	if(current_tick == tick):
		return
		
	current_tick = tick
	current_tick_played = false

func play(player):
	if current_tick_played:
		return
	
	var pitch = get_current_pitch()
	if pitch >= 0:
		player.play(pitch, 0)
	elif pitch == -2:
		player.stop()

func get_current_pitch():
	var song_position = current_tick