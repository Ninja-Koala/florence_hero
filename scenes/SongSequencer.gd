extends Node

onready var class_song = load("res://classes/Song.gd")

var ms_per_tick = 200
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
			if get_button_in_array(presses_remaining[i], button) != null:
				#remove the necessity to press the button
				erase_button_from_array(presses_remaining[i], button)
				found = true
				break
			elif get_button_in_array(releases_remaining[i], button) != null:
				#wrong operation order!
				break
		if !found:
			#unnecessary button press
			add_mistake(MistakeType.UnnecessaryPress, null)
	else:
		current_buttons[button] = ButtonState.Released
	
		#was the button release necessary?
		var found = false
		for i in range(0, releases_remaining.size()):
			if get_button_in_array(releases_remaining[i], button) != null:
				#remove the necessity to press the button
				erase_button_from_array(releases_remaining[i], button)
				found = true
				break
			elif get_button_in_array(presses_remaining[i], button) != null:
				#wrong operation order!
				break
		if !found:
			#unnecessary button release
			add_mistake(MistakeType.ReleasedTooEarly, null)

func get_button_in_array(array, button):
	for entry in array:
		if entry.button == button:
			return entry
	
	return false

func erase_button_from_array(array, button):
	for entry in array:
		if entry.button == button:
			array.erase(entry)
			return

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
	
	#get note to play
	var current_note = song.get_entry_at(tick)
	
	if tick == 28:
		pass
	
	#is there a note?
	var found = false
	if current_note != null:
		#has the user not played the note yet?
		for press_location in presses_remaining:
			for entry in press_location:
				var etick = entry.tick
				if entry.tick == tick:
					entry.not_played = true
					found = true
		
		#play the note
		if !found:
			if current_note.sound == -1:
				player.stop()
				player.play(current_note.pitch, current_note.sound)
	
	#play the tick
	#song.play_notes_at(player, tick)
	
	#normalize button states
	for i in range(0, 4):
		if current_buttons[i] == ButtonState.Pressed:
			current_buttons[i] = ButtonState.Held
		elif current_buttons[i] == ButtonState.Released:
			current_buttons[i] = ButtonState.None
	
	return tick - tick_before

func get_current_notes(offset, count):
	return song.get_notes_in_range(current_tick() + offset, count)

func get_current_offset():
	return (current_ms % ms_per_tick) / float(ms_per_tick)

func current_tick():
	return calculate_tick(current_ms)
	
func calculate_tick(ms):
	return ms / ms_per_tick

func add_mistake(type, entries):
	if type == MistakeType.UnnecessaryPress:
		print("mistake: unnecessary")
		#play random note
		player.play(randi()%10, randi()%2)
	elif type == MistakeType.NoteMissed:
		print("mistake: missed")
		#player.stop()
	elif type == MistakeType.ReleasedTooEarly:
		print("mistake: early")
	elif type == MistakeType.ReleasedTooLate:
		print("mistake: late")
		#play random note
		#player.play(randi()%10, randi()%2)

func update_queue(tick_tolerance_low, tick_tolerance_high):
	#has the lower tolerance bound shifted?
	if queue_position_ticks < tick_tolerance_low:
		#are there any presses left?
		for i in range(0, tick_tolerance_low - queue_position_ticks):
			if presses_remaining[0].size() > 0:
				#add one mistake for the missed notes
				add_mistake(MistakeType.NoteMissed, presses_remaining[0])
				
			#shift the presses
			presses_remaining.remove(0)
			
		#are there any releases left?
		for i in range(0, tick_tolerance_low - queue_position_ticks):
			if releases_remaining[0].size() > 0:
				#add one mistake for the missed releases
				add_mistake(MistakeType.ReleasedTooLate, releases_remaining[0])
				
			#shift the releases
			releases_remaining.remove(0)
		
		#store new queue position
		queue_position_ticks = tick_tolerance_low
	
	#has the upper tolerance bound shifted?
	var diff = tick_tolerance_high - queue_position_ticks - presses_remaining.size() + 1
	var start = tick_tolerance_high - diff + 1
	if diff > 0:
		var new_positions = song.get_notes_in_range(start, diff)
		for i in range(0, diff):
			presses_remaining.push_back([])
			releases_remaining.push_back([])
			for button in range(0, 4):
				if new_positions[i][0][button] == class_song.NoteType.Single:
					presses_remaining.back().push_back(ButtonEntry.new(ButtonEntryType.Press, button, start + i))
					releases_remaining.back().push_back(ButtonEntry.new(ButtonEntryType.Release, button, start + i))
				elif new_positions[i][0][button] == class_song.NoteType.Pressed:
					presses_remaining.back().push_back(ButtonEntry.new(ButtonEntryType.Press, button, start + i))
				elif new_positions[i][0][button] == class_song.NoteType.Released:
					releases_remaining.back().push_back(ButtonEntry.new(ButtonEntryType.Release, button, start + i))

class ButtonEntry:
	var type
	var button
	var tick
	var not_played
	
	func _init(type, button, tick):
		self.type = type
		self.button = button
		self.tick = tick

enum ButtonEntryType {
	Press,
	Release
}

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