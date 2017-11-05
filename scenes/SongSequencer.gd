extends Node

signal stage_direction(name)
signal score_points(points)
signal made_mistake(type)

const NOTE_PRESS_POINTS = 10
const NOTE_HOLD_POINTS = 5
const NOTE_RELEASE_POINTS = 2

const MIN_RANDOM = 0
const MAX_RANDOM = 10

onready var class_song = load("res://classes/Song.gd")

var ms_per_tick = 200
var before_tolerance_ms = 100
var after_tolerance_ms = 100

var punish = true

var player
var piano_player
var song

var current_ms = 0
var current_buttons = [ButtonState.None,  ButtonState.None, ButtonState.None, ButtonState.None]

var presses_remaining = [[]]
var releases_remaining = [[]]
var holds_remaining = [[]]
var queue_position_ticks = 0
var finished = false

var current_sounds = [false, false, false, false]

func initialize(player, piano_player, song):
	self.player = player
	self.piano_player = piano_player
	self.song = song

func set_sound_state(sound, new_state):
	var sound_before = current_sounds.find_last(true)
	current_sounds[sound] = new_state
	var sound_after = current_sounds.find_last(true)
	
	#get current button
	var button = -1
	for i in range(current_buttons.size()):
		if current_buttons[i] == ButtonState.Pressed || current_buttons[i] == ButtonState.Held:
			button = i
			break
	
	if button != -1:
		if sound_before != sound_after:
			if sound_before != -1:
				handle_note_release_action(button, sound_before)
			if sound_after != -1:
				handle_note_press_action(button, sound_after)

func set_button_state(button, new_state):
	var sound = current_sounds.find_last(true)
	
	if new_state:
		if current_buttons[button] == ButtonState.Pressed || current_buttons[button] == ButtonState.Held:
			return
			
		current_buttons[button] = ButtonState.Pressed
		if sound != -1:
			handle_note_press_action(button, sound)
	else:
		if current_buttons[button] == ButtonState.Released || current_buttons[button] == ButtonState.None:
			return
			
		current_buttons[button] = ButtonState.Released
		if sound != -1:
			handle_note_release_action(button, sound)

func handle_note_press_action(button, sound):
	#was the button press necessary?
	var found = false
	for i in range(0, presses_remaining.size()):
		var entry = get_button_in_array(presses_remaining[i], button, sound)
		if entry != null:
			#does the note need to be played?
			if entry.not_played:
				#play the note
				var note = song.get_entry_at(entry.tick)
				if note != null && note.sound != -1:
					player.stop()
					player.play(note.pitch, note.sound)
				
			#remove the necessity to press the button
			erase_button_from_array(presses_remaining[i], button)
			found = true
			emit_signal("score_points", NOTE_PRESS_POINTS)
			break
		elif get_button_in_array(releases_remaining[i], button, sound) != null:
			#wrong operation order!
			break
	if !found:
		#unnecessary button press
		add_mistake(MistakeType.UnnecessaryPress, null)

func handle_note_release_action(button, sound):
	#was the button release necessary?
	var found = false
	for i in range(0, releases_remaining.size()):
		if get_button_in_array(releases_remaining[i], button, sound) != null:
			#remove the necessity to press the button
			erase_button_from_array(releases_remaining[i], button)
			found = true
			emit_signal("score_points", NOTE_RELEASE_POINTS)
			break
		elif get_button_in_array(presses_remaining[i], button, sound) != null:
			#wrong operation order!
			break
	if !found:
		#unnecessary button release
		add_mistake(MistakeType.ReleasedTooEarly, null)

func get_button_in_array(array, button, sound):
	for entry in array:
		if entry.button == button && entry.sound == sound:
			return entry
	
	return null

func erase_button_from_array(array, button):
	for entry in array:
		if entry.button == button:
			array.erase(entry)
			return

func advance(ms):
	#song finished?
	if finished:
		return 0
	
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
		piano_player.stop()
		finished = true
		return
	
	#get note to play
	var current_note = song.get_entry_at(tick)
	
	#is there a note?
	var found = false
	if current_note != null:
		#send stage directions
		if current_note.stage_direction != null:
			emit_signal("stage_direction", current_note.stage_direction)
		
		#play the piano
		if current_note.sound >= 0:
			piano_player.play(current_note.pitch)
		
		#has the user not played the note yet?
		if punish && (current_note.buttons.count(class_song.NoteType.Single) != 0 || current_note.buttons.count(class_song.NoteType.Pressed) != 0 || current_note.buttons.count(class_song.NoteType.Released) != 0):
			for press_location in presses_remaining:
				for entry in press_location:
					if entry.tick == tick:
						entry.not_played = true
						found = true
		
		#was a button press or a single note needed here?
		if found && (current_note.buttons.count(class_song.NoteType.Single) != 0 || current_note.buttons.count(class_song.NoteType.Pressed) != 0):
			player.stop()
		
		#has the user held the button correctly?
		for i in range(current_note.buttons.size()):
			if current_note.buttons[i] == class_song.NoteType.Held:
				if current_buttons[i] == ButtonState.Pressed || current_buttons[i] == ButtonState.Held:
					#award points for holding the note
					emit_signal("score_points", NOTE_HOLD_POINTS)
		
		#play the note
		if !found:
			var sound = current_note.sound
			if current_note.sound >= 0:
				player.stop()
				player.play(current_note.pitch, current_note.sound)
			elif current_note.sound == -2:
				player.stop()
	
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
		if punish:
			player.play(randi() % (MAX_RANDOM - MIN_RANDOM) + MIN_RANDOM, randi() % 4)
		emit_signal("made_mistake", type)
	elif type == MistakeType.NoteMissed:
		print("mistake: missed")
		#if punish:
			#player.stop()
		emit_signal("made_mistake", type)
	elif type == MistakeType.ReleasedTooEarly:
		print("mistake: early")
		if punish:
			player.stop()
	elif type == MistakeType.ReleasedTooLate:
		print("mistake: late")
		#play random note
		if punish:
			player.play(randi() % (MAX_RANDOM - MIN_RANDOM) + MIN_RANDOM, randi() % 4)
	elif type == MistakeType.NotHeld:
		print("mistake: not held")
	elif type == MistakeType.NotReleased:
		print("mistake: not released")

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
				#get all the releases where the button is actually still down
				var late_releases = []
				var ignored_releases = []
				for release in releases_remaining[0]:
					if current_sounds.find_last(true) > 0 && (current_buttons[release.button] == ButtonState.Pressed || current_buttons[release.button] == ButtonState.Held):
						late_releases.push_back(release)
					else:
						ignored_releases.push_back(release)
				
				#add one mistake for the missed releases
				if late_releases.size() > 0:
					add_mistake(MistakeType.ReleasedTooLate, late_releases)
					
				#add one mistake for the ignored releases
				if ignored_releases.size() > 0:
					add_mistake(MistakeType.NotReleased, ignored_releases)
				
			#shift the releases
			releases_remaining.remove(0)
			
		#are there any holds left?
		for i in range(0, tick_tolerance_low - queue_position_ticks):
			if holds_remaining[0].size() > 0:
				#add one mistake for the missed holds
				add_mistake(MistakeType.NotHeld, releases_remaining[0])
				
			#shift the releases
			holds_remaining.remove(0)
		
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
			holds_remaining.push_back([])
			if new_positions[i] != null:
				for button in range(0, 4):
					if new_positions[i].buttons[button] == class_song.NoteType.Single:
						presses_remaining.back().push_back(ButtonEntry.new(ButtonEntryType.Press, button, new_positions[i].sound, start + i))
						releases_remaining.back().push_back(ButtonEntry.new(ButtonEntryType.Release, button, new_positions[i].sound, start + i))
					elif new_positions[i].buttons[button] == class_song.NoteType.Pressed:
						presses_remaining.back().push_back(ButtonEntry.new(ButtonEntryType.Press, button, new_positions[i].sound, start + i))
					elif new_positions[i].buttons[button] == class_song.NoteType.Released:
						releases_remaining.back().push_back(ButtonEntry.new(ButtonEntryType.Release, button, new_positions[i].sound, start + i))
					elif new_positions[i].buttons[button] == class_song.NoteType.Held:
						holds_remaining.back().push_back(ButtonEntry.new(ButtonEntryType.Hold, button, new_positions[i].sound, start + i))

class ButtonEntry:
	var type
	var button
	var tick
	var sound
	var not_played
	
	func _init(type, button, sound, tick):
		self.type = type
		self.button = button
		self.sound = sound
		self.tick = tick

enum ButtonEntryType {
	Press,
	Hold,
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
	ReleasedTooLate,
	NotHeld,
	NotReleased
}