extends Node2D

onready var eyelids = $Gesicht/Augenlider
onready var chin = $Gesicht/Unterlippe
onready var upper_lip = $Gesicht/Oberlippe
onready var cheeks = $"Gesicht/Bäckchen"

var chin_transform
var upper_lip_transform

var eyes_closed = false
var eye_blink_time = 0

var mouth_closed = false

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
	if mouth_closed:
		chin.transform = chin_transform
		upper_lip.transform = upper_lip_transform
	else:
		chin.transform = chin_transform * Transform2D (0, Vector2 (12,24) * percent)
		if percent > 0.7:
			upper_lip.transform = upper_lip_transform * Transform2D (0, Vector2 (-2,-8) * (percent - 0.7) / 0.3)
		else:
			upper_lip.transform = upper_lip_transform


func smile (state):
	if state:
		eyes_open (false)
		open_mouth (0)
		mouth_closed = true
		cheeks.show ()
	else:
		eyes_open (true)
		mouth_closed = false
		cheeks.hide ()
	

func _input (event):
	if event.is_action_pressed ("face_smile"):
		smile (true)
	elif event.is_action_released ("face_smile"):
		smile (false)
	
	if event.is_action_pressed ("face_eyes_open"):
		eyes_open (true)
	
	if event.is_action_pressed ("face_eyes_close"):
		eyes_open (false)
		
	
func _process (delta):
	eye_blink_time += delta
	if eye_blink_time > 4:
		eye_blink_time = 0
		
	if eye_blink_time < 3.9 and not eyes_closed:
		eyelids.hide ()
	else:
		eyelids.show ()
		
	open_mouth ((1 + sin (3 * (eye_blink_time / 2.0 * PI))) / 2)

