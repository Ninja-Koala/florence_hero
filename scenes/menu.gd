extends Node2D

onready var main_scene = load("res://scenes/Main.tscn")

func _ready():
	pass

func _on_Button1_button_down():
	get_tree().change_scene_to(main_scene)

func _on_Button2_button_down():
	get_tree().change_scene_to(main_scene)
