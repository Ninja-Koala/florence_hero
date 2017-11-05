extends Node2D

onready var main_scene = load("res://scenes/Main.tscn")
onready var song_selector = get_node("/root/song_selector")

func _ready():
	pass

func _on_Button1_button_down():
	song_selector.song_path = "res://songs/DemoSong1.txt"
	get_tree().change_scene_to(main_scene)
	

func _on_Button2_button_down():
	song_selector.song_path = "res://songs/mozart_queen.txt"
	get_tree().change_scene_to(main_scene)
