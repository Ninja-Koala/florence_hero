extends Node

onready var tone_player = get_node("TonePlayer")

var effect = AudioServer.get_bus_effect(2, 0)
const PITCH_MIN = 1.0595

var current_pitch = -1

func play(pitch):
	tone_player.stop()
	effect.set_pitch_scale(pow(PITCH_MIN, pitch))
	tone_player.play(0)
	current_pitch = pitch

func stop():
	tone_player.stop()
	current_pitch = -1