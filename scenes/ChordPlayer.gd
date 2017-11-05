extends Node

var effects = []
const PITCH_MIN = 1.0595

var players = []

func _ready():
	for i in range(3):
		players.push_back(get_node("NotePlayer" + str(i)))
		effects.push_back(AudioServer.get_bus_effect(4 + i, 0))

func play_chord(pitches):
	for i in range(players.size()):
		players[i].stop()
		if i < pitches.size():
			effects[i].set_pitch_scale(2 * pow(PITCH_MIN, pitches[i]))
			players[i].play(0)

func stop():
	for player in players:
		player.stop()