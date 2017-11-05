extends Node

var effects = []
const PITCH_MIN = 1.0595

const PLAYERS_COUNT = 4

var players = []

func _ready():
	for i in range(PLAYERS_COUNT):
		players.push_back(get_node("NotePlayer" + str(i)))
		effects.push_back(AudioServer.get_bus_effect(4 + i, 0))

func get_max_chord_size():
	return PLAYERS_COUNT

func play_chord(pitches):
	for i in range(players.size()):
		players[i].stop()
		if i < pitches.size():
			effects[i].set_pitch_scale(pow(PITCH_MIN, pitches[i]))
			players[i].play(0)

func stop():
	for player in players:
		player.stop()