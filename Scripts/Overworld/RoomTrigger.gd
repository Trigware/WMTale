extends Area2D

@export var roomDestination := Overworld.Room.ErrorHandlerer

const scene_hide_duration := 0.4

func on_body_entered(body: Node2D):
	if not body.is_in_group("Player"): return
	Overlay.hide_scene(scene_hide_duration)
	await Overlay.finished
	Overlay.show_scene(scene_hide_duration)
	Overworld.load_room(roomDestination)
