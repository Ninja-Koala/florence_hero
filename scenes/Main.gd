extends Node2D

onready var menu_scene = load("res://scenes/menu.tscn")
onready var menubutton = $"MenuButton"

func _input(event):
	if event.is_action_pressed ("fullscreen"):
		OS.set_window_fullscreen (not OS.is_window_fullscreen ())

func _ready():
	menubutton.hide ()


func _on_MenuButton_pressed():
	get_tree().change_scene_to(menu_scene)


func _on_SongSequencer_song_finished():
	menubutton.show ()
