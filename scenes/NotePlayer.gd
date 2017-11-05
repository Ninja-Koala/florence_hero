extends Node

signal note_played(pitch, sound)
signal stopped()

var effect = AudioServer.get_bus_effect(1, 0)
const PITCH_MIN = 1.0595

var current_sound = -1
var current_pitch = -1

func play(pitch, sound):
	if current_sound != sound:
		if current_sound >= 0:
			get_node("TonePlayer" + str(current_sound)).stop()
	elif current_pitch == pitch:
		return
	
	if sound >= 0:
		effect.set_pitch_scale(pow(PITCH_MIN, pitch))
		get_node("TonePlayer" + str(sound)).play(0)
	
	current_sound = sound
	current_pitch = pitch
	
	emit_signal("note_played", pitch, sound)

func stop():
	if current_sound >= 0:
		get_node("TonePlayer" + str(current_sound)).stop()
	
	current_sound = -1
	current_pitch = -1
	
	emit_signal("stopped")