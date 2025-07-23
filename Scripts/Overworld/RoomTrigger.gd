extends Area2D

@export var roomDestination := Overworld.Room.ErrorHandlerer
@export var new_position := Vector2.ZERO
@export var x_player_dependent := false
@export var y_player_dependent := false

const scene_hide_duration := 0.4

func on_body_entered(body: Node2D):
	if not body.is_in_group("Player"): return
	Overlay.hide_scene(scene_hide_duration)
	await Overlay.finished
	Overlay.show_scene(scene_hide_duration)
	Overworld.load_room(roomDestination, get_enterance_effected_position())

func get_enterance_effected_position():
	var playerPos = Player.get_global_pos()
	var anchorPosition = new_position
	var newPlayerPosition = Vector2.ZERO
	if x_player_dependent:
		anchorPosition.y -= 32
		newPlayerPosition.x += playerPos.x
	if y_player_dependent:
		anchorPosition.y -= 32
		newPlayerPosition.y += playerPos.y
	newPlayerPosition += anchorPosition * Overworld.scaleConst
	return newPlayerPosition
