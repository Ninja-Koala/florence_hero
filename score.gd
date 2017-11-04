extends Label

onready var song_seq = get_node("../SongSequencer")

var cur_score = 0

func _ready():
	song_seq.connect("score_points", self, "update_score")
	set_text("Score: "+str(cur_score))
	
func update_score(score_val):
	print(score_val)
	cur_score += score_val
	set_text("Score: "+str(cur_score))
