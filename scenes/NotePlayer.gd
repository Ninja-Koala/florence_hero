extends Node

signal note_played(pitch, sound)
signal stopped()

var effect = AudioServer.get_bus_effect(1, 0)
const PITCH_MIN = 1.0595

var players = []

var current_sound = -1
var current_pitch = -1
var current_planned = true

func _ready():
	for i in range(4):
		players.push_back(get_node("TonePlayer" + str(i)))

func is_playing_planned():
	return current_planned && current_sound >= 0

func play(pitch, sound, planned):
	current_planned = planned
	
	if current_sound != sound:
		if current_sound >= 0:
			players[current_sound].stop()
	elif current_pitch == pitch:
		return
	
	if sound >= 0:
		effect.set_pitch_scale(pow(PITCH_MIN, pitch))
		players[sound].play(0)
	
	current_sound = sound
	current_pitch = pitch
	
	emit_signal("note_played", pitch, sound)

func stop_planned():
	if current_planned:
		if current_sound >= 0:
			players[current_sound].stop()
		
		current_sound = -1
		current_pitch = -1
		current_planned = true
		
		emit_signal("stopped")

func stop_all():
	if current_sound >= 0:
		players[current_sound].stop()
	
	current_sound = -1
	current_pitch = -1
	current_planned = true
	
	emit_signal("stopped")