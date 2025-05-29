extends Control

func _ready():
	Overlay.hide_overlay()
	Overlay.show_scene()

func _process(_delta: float):
	if Input.is_anything_pressed():
		Overlay.change_scene("res://Scenes/Legend.tscn")
