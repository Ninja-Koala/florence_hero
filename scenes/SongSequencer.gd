extends Node

var ms_per_tick = 200
var ticks_per_note = 5
var before_tolerance = 1
var after_tolerance = 1

var player
var song

var current_ms = 0
var current_buttons = [ButtonState.None,  ButtonState.None, ButtonState.None, ButtonState.None]

func initialize(player, song):
	self.player = player
	self.song = song

func set_button_state(var button, var new_state):
	if new_state:
		current_buttons[button] = ButtonState.Pressed
	else:
		current_buttons[button] = ButtonState.Released

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
	
	#normalize button states
	for i in range(0, 4):
		if current_buttons[i] == ButtonState.Pressed:
			current_buttons[i] = ButtonState.Held
		elif current_buttons[i] == ButtonState.Released:
			current_buttons[i] = ButtonState.None

func get_current_notes(var count):
	return song.get_notes_in_range(current_tick(), count)

func get_current_offset():
	return float(ms_per_tick) / (current_ms % ms_per_tick)

func current_tick():
	return current_ms / ms_per_tick

func get_score(var buttons):
	var notes = song.get_notes_in_range(current_tick())[0]
	return notes == buttons

enum ButtonState {
	None,
	Pressed,
	Held,
	Released
}