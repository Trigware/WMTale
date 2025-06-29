extends Node

@export var audioArea : Area2D

func _process(_delta):
	var bodies = audioArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			Player.sink_underwater()
			return
