extends Node2D

onready var eyelids = $Gesicht/Augenlider
onready var chin = $Gesicht/Unterlippe
onready var upper_lip = $Gesicht/Oberlippe

var chin_transform
var upper_lip_transform

var eyes_closed = false
var eye_blink_time = 0

func _ready():
	chin_transform = chin.transform
	upper_lip_transform = upper_lip.transform

func eyes_open (state):
	if state:
		eyelids.hide ()
		eyes_closed = false
		eye_blink_time = 0
	else:
		eyelids.show ()
		eyes_closed = true

func open_mouth (percent):
	chin.transform = chin_transform * Transform2D (0, Vector2 (12,24) * percent)
	if percent > 0.7:
		upper_lip.transform = upper_lip_transform * Transform2D (0, Vector2 (-2,-8) * (percent - 0.7) / 0.3)

	
func _process (delta):
	eye_blink_time += delta
	if eye_blink_time > 4:
		eye_blink_time = 0
		
	if eye_blink_time < 3.9 and not eyes_closed:
		eyelids.hide ()
	else:
		eyelids.show ()
		
	open_mouth ((1 + sin (3 * (eye_blink_time / 2.0 * PI))) / 2)

