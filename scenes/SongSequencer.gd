extends Node

onready var class_song = load("res://classes/Song.gd")

var ms_per_tick = 100
var before_tolerance_ms = 100
var after_tolerance_ms = 100

var player
var song

var current_ms = 0
var current_buttons = [ButtonState.None,  ButtonState.None, ButtonState.None, ButtonState.None]

var presses_remaining = [[]]
var releases_remaining = [[]]
var queue_position_ticks = 0

func initialize(player, song):
	self.player = player
	self.song = song

func set_button_state(button, new_state):
	if new_state:
		current_buttons[button] = ButtonState.Pressed
		
		#was the button press necessary?
		var found = false
		for i in range(0, presses_remaining.size()):
			if presses_remaining[i].has(button):
				#remove the necessity to press the button
				presses_remaining[i].erase(button)
				found = true
				break
			elif releases_remaining[i].has(button):
				#wrong operation order!
				break
		if !found:
			#unnecessary button press
			add_mistake(MistakeType.UnnecessaryPress)
	else:
		current_buttons[button] = ButtonState.Released
	
		#was the button release necessary?
		var found = false
		for i in range(0, releases_remaining.size()):
			if releases_remaining[i].has(button):
				#remove the necessity to press the button
				releases_remaining[i].erase(button)
				found = true
				break
			elif presses_remaining[i].has(button):
				#wrong operation order!
				break
		if !found:
			#unnecessary button release
			add_mistake(MistakeType.ReleasedTooEarly)

func advance(ms):
	#calculate position before and after the advancement
	var tick_before = current_tick()
	current_ms += int(ms)
	var tick = current_tick()
	
	#calculate positions before and after tolerance
	var tick_tolerance_low = calculate_tick(current_ms - before_tolerance_ms)
	var tick_tolerange_high = calculate_tick(current_ms + after_tolerance_ms)
	
	#update the nevessary presses and releases
	update_queue(tick_tolerance_low, tick_tolerange_high)
	
	#has the song not advanced?
	if tick <= tick_before:
		return 0
		
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
	
	return tick - tick_before

func get_current_notes(count):
	return song.get_notes_in_range(current_tick(), count)

func get_current_offset():
	return (current_ms % ms_per_tick) / float(ms_per_tick)

func current_tick():
	return calculate_tick(current_ms)
	
func calculate_tick(ms):
	return ms / ms_per_tick

func add_mistake(type):
	if type == MistakeType.UnnecessaryPress:
		print("missed: unnecessary")
	elif type == MistakeType.NoteMissed:
		print("missed: missed")
	elif type == MistakeType.ReleasedTooEarly:
		print("missed: early")
	elif type == MistakeType.ReleasedTooLate:
		print("missed: late")

func update_queue(tick_tolerance_low, tick_tolerance_high):
	#has the lower tolerance bound shifted?
	if queue_position_ticks < tick_tolerance_low:
		#are there any presses left?
		for i in range(0, tick_tolerance_low - queue_position_ticks):
			if presses_remaining[0].size() > 0:
				#add one mistake for the missed notes
				add_mistake(MistakeType.NoteMissed)
				
			#shift the presses
			presses_remaining.remove(0)
			
		#are there any releases left?
		for i in range(0, tick_tolerance_low - queue_position_ticks):
			if releases_remaining[0].size() > 0:
				#add one mistake for the missed releases
				add_mistake(MistakeType.ReleasedTooLate)
				
			#shift the releases
			releases_remaining.remove(0)
		
		#store new queue position
		queue_position_ticks = tick_tolerance_low
	
	#has the upper tolerance bound shifted?
	var diff = tick_tolerance_high - queue_position_ticks - presses_remaining.size() + 1
	if diff > 0:
		var new_positions = song.get_notes_in_range(tick_tolerance_high, diff)
		for i in range(0, diff):
			presses_remaining.push_back([])
			releases_remaining.push_back([])
			for button in range(0, 4):
				if new_positions[i][button] == class_song.NoteType.Single:
					presses_remaining.back().push_back(button)
					releases_remaining.back().push_back(button)
				elif new_positions[i][button] == class_song.NoteType.Pressed:
					presses_remaining.back().push_back(button)
				elif new_positions[i][button] == class_song.NoteType.Released:
					releases_remaining.back().push_back(button)

enum ButtonState {
	None,
	Pressed,
	Held,
	Released
}

enum MistakeType {
	UnnecessaryPress,
	NoteMissed,
	ReleasedTooEarly,
	ReleasedTooLate
}