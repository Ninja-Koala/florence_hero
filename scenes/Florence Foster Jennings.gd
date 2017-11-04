extends Node2D

onready var eyelids        = $"Gesicht/Augenlider"
onready var orig_eye_left  = $"Gesicht/linkes Auge"
onready var orig_eye_right = $"Gesicht/rechtes Auge"
onready var eye_pupils     = $"Gesicht/Pupillen"
onready var chin           = $"Gesicht/Unterlippe"
onready var upper_lip      = $"Gesicht/Oberlippe"
onready var cheeks         = $"Gesicht/Bäckchen"
onready var face           = $"Gesicht"

var chin_transform
var upper_lip_transform
var eye_pupils_transform
var face_transform

var target_face_position = 0
var cur_face_position = 0

var eyes_closed = false
var eye_blink_time = 0
var eye_pupils_position = 0

var mouth_closed = false


func _ready():
	var rot_origin = Vector2 (470, 570)
	face.transform *= Transform2D (0, rot_origin)
	for n in face.get_children ():
		n.transform *= Transform2D (0, -rot_origin)
		
	face_transform = face.transform
	chin_transform = chin.transform
	upper_lip_transform = upper_lip.transform
	eye_pupils_transform = eye_pupils.transform


func eyes_open (state):
	if state:
		eyelids.hide ()
		eyes_closed = false
		eye_blink_time = 0
	else:
		eyelids.show ()
		eyes_closed = true


func eyes_position (state, pos):
	if state:
		orig_eye_left.hide ()
		orig_eye_right.hide ()
		eye_pupils.transform = eye_pupils_transform * Transform2D (0, Vector2 (20,-5) * pos)
	else:
		orig_eye_left.show ()
		orig_eye_right.show ()


func open_mouth (percent):
	percent = clamp (percent, 0, 1)
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


func on_note_played (pitch, sound):
	target_face_position = clamp (0.5 - pitch * 0.1, -1, 1)
	open_mouth (0.3 + 0.6 * pitch / 6)


func on_note_stopped ():
	target_face_position = 0
	open_mouth (0)


func tilt_face (pos):
	if pos < 0:
		pos = clamp (pos * 0.075, -0.075, 0)
	else:
		pos = clamp (pos * 0.125, 0, 0.125)
		
	face.transform = face_transform * Transform2D (pos * PI, Vector2 (70,30) * pos)


func recalc_face_tilt ():
	var delta

	delta = target_face_position - cur_face_position
	delta = delta * 0.2
	delta = clamp (delta, -0.2, 0.2)

	cur_face_position += delta
	tilt_face (cur_face_position)


func _input (event):
	if event.is_action_pressed ("face_smile"):
		smile (true)
	elif event.is_action_released ("face_smile"):
		smile (false)
	
	if event.is_action_pressed ("face_eyes_open"):
		eyes_open (true)
	
	if event.is_action_pressed ("face_eyes_close"):
		eyes_open (false)

	if event.is_action_pressed ("face_eyes_reset"):
		eyes_position (false, 0)

	if event.is_action_pressed ("face_eyes_left"):
		eye_pupils_position = clamp (eye_pupils_position + 0.1, 0.0, 1.0)
		eyes_position (true, eye_pupils_position)

	if event.is_action_pressed ("face_eyes_right"):
		eye_pupils_position = clamp (eye_pupils_position - 0.1, 0.0, 1.0)
		eyes_position (true, eye_pupils_position)

	if event.is_action_pressed ("face_nod_reset"):
		if target_face_position < -0.5:
			target_face_position = 0
		elif target_face_position < 0.5:
			target_face_position = 1
		else:
			target_face_position = -1

	if event.is_action_pressed ("face_nod_forward"):
		target_face_position = clamp (target_face_position + 0.1, -1.0, 1.0)

	if event.is_action_pressed ("face_nod_backward"):
		target_face_position = clamp (target_face_position - 0.1, -1.0, 1.0)


func _process (delta):
	eye_blink_time += delta
	if eye_blink_time > 4:
		eye_blink_time = 0

	if eye_blink_time < 3.9 and not eyes_closed:
		eyelids.hide ()
	else:
		eyelids.show ()

	recalc_face_tilt ()
