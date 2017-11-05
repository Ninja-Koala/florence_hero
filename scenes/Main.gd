extends Node2D

func _input(event):
	if event.is_action_pressed ("fullscreen"):
		OS.set_window_fullscreen (not OS.is_window_fullscreen ())

func _ready():
	pass

